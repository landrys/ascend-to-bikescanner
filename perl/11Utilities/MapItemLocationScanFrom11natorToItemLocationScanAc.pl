#!/usr/bin/perl -w

#
# This script will create the ascend ILS entries from  eleven's ILS entries.
# the id will be the same but the customer and will be populated as a name if sold 
#  
#  id                      -> id
#  serialized              -> serialized ( but points to the new ascend_serialezed table )
#  scan_location           -> scan_location
#  destination_location    -> destination_location
#  employee                -> employee
#  action                  -> action
#  timestamp               -> timestamp
#  last_modified           -> last_modified
# 
#DBI is the standard database interface for Perl
#DBD is the Perl module that we use to connect to the <a href=http://mysql.com/>MySQL</a> database
use v5.16;
use DateTime::Format::Strptime;
use MyModules::MySql;
use MyModules::Bean::ItemLocationScan;
use MyModules::Bean::Result;
use Data::Dumper;
use JSON::Parse 'json_file_to_perl';
no strict;
use warnings;

$|=1;
my $elevebTestDB;
my $elevebProdDB;

my $quiet = 1;

if ( $ARGV[0] ) {
    $quiet = 0;
}

my $myPrivateData = json_file_to_perl('privateData');

#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------

connectToDBs();

my $finished = 0;
while (!$finished) {
	processNewEntries(); 
}

$elevenTestDB->close();
$elevenProdDB->close();

exit;

sub connectToDBs {

    $elevenTestDB = MyModules::MySql->new(
        database => $myPrivateData->{'database'},
        host  => $myPrivateData->{'localHost'},
        user   => $myPrivateData->{'localHostUser'},
        password   => $myPrivateData->{'localHostPassword'} 
    );

    $elevenTestDB->connect();

    $elevenProdDB = MyModules::MySql->new(
        database => $myPrivateData->{'database'},
        host  => $myPrivateData->{'remoteHost'},
        user   => $myPrivateData->{'remoteHostUser'},
        password   => $myPrivateData->{'remoteHostPassword'}
    );

    $elevenProdDB->connect();

}

sub processNewEntries {

    my $maxIlsAcId = getMaxIlsAcId();

    if ( !$quiet ) {
        say $maxIlsAcId;
    }

    # get any new ones from the ils table 
    #my $statement = $elevenProdDB->prepare("select * from item_location_scan ils join serialized s on s.id=ils.serialized where ils.id > ?  and s.lc_deleted is not true limit 100");
    my $statement = $elevenProdDB->prepare("select ils.id as id, ils.serialized as serialized, ils.scan_location as scan_location, ils.destination_location as destination_location, ils.employee as employee, ils.action as action, ils.timestamp as timestamp, ils.last_modified as last_modified from item_location_scan ils join serialized s on s.id=ils.serialized where ils.id > ?  and s.lc_deleted is not true order by ils.id asc limit 100");
    if ( !defined($maxIlsAcId) || ($maxIlsAcId eq 'NULL') )  {
	    $maxIlsAcId = 0;
    }

    my $count = $statement->execute($maxIlsAcId);

    # Print out a . for checking new entries if no new one were found
    # so that user knows we are still working.
    if ( $count == 0 ) {
	    if ( !$quiet ) {
		    say 'None to process. Getting out.';
	    }
	    $statement->finish;
	    $finished = 1;
	    return;
    }

    my @newIlsModels = getNewIlsEntries($statement);

    foreach ( @newIlsModels ) {

	my $result = createIlsAcEntry($_);

        if( !$result->status() ) { 
            say("\nCould not create ILS entry with id: " . $_->id());
            my $substr = 'foreign key constraint fails (`eleven`.`item_location_scan_ac`, CONSTRAINT `item_location_scan_ac_ibfk_1` FOREIGN KEY (`serialized`) REFERENCES `ascend_serialized`';
            if (index($result->error, $substr) == -1) {
               return;
            } 
            say('Ignoring constraint error and moving on...');
            #$finished = 1;
            #return; # Just get out as we are adding from prod so id ane employee or location is missing need to sync up tables
        } else {
    if ( !$quiet ) {
            say("\nCreated ascend ItemLocationScan Entry: " . $_->id());
    }
        }
        #say Dumper($result);
    }
    $statement->finish;

}

sub getMaxIlsAcId {
    my $statement = $elevenTestDB->prepare("select max(id) from item_location_scan_ac");
    my $resultExecute = $statement->execute();
    return $statement->fetchrow_hashref->{'max(id)'};
}


sub createIlsAcEntry {

	my $model = shift; 
	my $result = MyModules::Bean::Result->new();

	my $statement = $elevenTestDB->prepare("insert into item_location_scan_ac values(?,?,?,?,?,?,?,?,?)");
	my $resultExecute = $statement->execute(
			$model->id(), 
			$model->serialized(), 
#			1, 
			$model->scan_location(), 
			$model->destination_location(), 			
			$model->employee(), 
			$model->action(), 
			$model->timestamp(), 
			$model->last_modified(),
			0
			);

	if ( $statement->err ) {
		say $statement->errstr;
		say $statement->err;
		$result->status(0);
		$result->error($statement->errstr);
	} else {
		$result->entityId($model->id());
		$result->status(1);
		$result->otherInfo('Model with id ' . $model->id . ' created in duraAce.');
	}

	return $result;
}

sub getNewIlsEntries {

    my $statement = shift;
    my @newEntries;
    while(my $ref = $statement->fetchrow_hashref)
    {
        #say Dumper($ref);
        my $model = MyModules::Bean::ItemLocationScan->new(
            id => $ref->{'id'},
            serialized => $ref->{'serialized'},
            scan_location => $ref->{'scan_location'},
            destination_location => $ref->{'destination_location'},
            employee => $ref->{'employee'},
            action => $ref->{'action'},
            timestamp => $ref->{'timestamp'},
            last_modified => $ref->{'last_modified'}
        );
        push @newEntries, $model;
    }
    return @newEntries;
}
sub buildDatetime {
        my $date = shift;
#'%F        %H:%M:%S'
#2017-03-03 23:00:00
        my $parser = DateTime::Format::Strptime->new(
                        pattern => '%F %H:%M:%S',
                        on_error => 'croak',
                        );

        return $parser->parse_datetime($date);
}



sub buildAscendSerializedModel {

	my $serializedModel = shift;
	my $model = MyModules::Bean::AscendSerialized->new(
		id => $serializedModel->id(),
		serial => $serializedModel->serial(),
		itemNo => $serializedModel->itemId(),
		description => $serializedModel->description(),
		customerNo => $serializedModel->customerId(),
		customer => getCustomerName($serializedModel->customerId(),$serializedModel->saleLineId()),
		lastModified => $serializedModel->lastModified()
	);

	return $model;
}


sub getCustomerName {

	my $customerId = shift;
	my $saleLineId = shift;
	my $name;

	if ( !defined $customerId ) {
		my $statement = $elevenProdDB->prepare("select customer from sale_line where id=?");
		$statement->execute($saleLineId);
		my $ref2 = $statement->fetchrow_hashref;
		$customerId = $ref2->{'customer'};
	}

	if ( defined $customerId ) {
		my $statement = $elevenProdDB->prepare("select concat(first_name,' ', last_name) as name from customer where id=?");
		$statement->execute($customerId);
		my $ref2 = $statement->fetchrow_hashref;
		$name =  $ref2->{'name'};
	}

	return $name;
}
