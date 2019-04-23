#!/usr/bin/perl -w

#
# This script will create the ascend serialized entries from  eleven's serialized entry.
# the id will be the same but the customer and will be populated as a name if sold 
#  id -> id
#  serial -> serial
#  description -> description
#  item_id -> item_no
#  custmor_id -> customer
#  
# 
#DBI is the standard database interface for Perl
#DBD is the Perl module that we use to connect to the <a href=http://mysql.com/>MySQL</a> database
use v5.16;
use DateTime::Format::Strptime;
use MyModules::MySql;
use MyModules::Bean::Serialized;
use MyModules::Bean::AscendSerialized;
use MyModules::Bean::Result;
use Data::Dumper;
use JSON::Parse 'json_file_to_perl';

no strict;
use warnings;

$|=1;

my @listOfSerializeds;
my $placeholders;

my $quiet = 1;
if ( $ARGV[0] ) {
    $quiet = 0;
}

my $myPrivateData = json_file_to_perl('privateData');

if (!$ARGV[1]) {
    say 'Nothing input';
} else {
    
    @listOfSerializeds = split /,/,$ARGV[1];

    foreach ( @listOfSerializeds ) {
        say $_;
    }

    $placeholders = join ", ", ("?") x @listOfSerializeds;
}

my $elevenTestDB;
my $elevenProdDB;

#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------

connectToDBs();

processEntries(); 

$elevenTestDB->close();
$elevenProdDB->close();

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

sub processEntries {

    my $statement = $elevenProdDB->prepare("select * from serialized where id in ($placeholders) and serial is not null and lc_deleted is null");
    my $count = $statement->execute(@listOfSerializeds);

    # Print out a . for checking new entries if no new one were found
    # so that user knows we are still working.
    if ( $count == 0 ) {
        if ( !$quiet ) {
            say 'None to process. Getting out.';
        }
       $statement->finish;
       return;
    } else {
        say 'Got ' . $count . ' to process';
    }

    my @newSerializedModels = getNewSerializedEntries($statement);

    foreach ( @newSerializedModels ) {

	my $result = createAscendSerializedEntry($_);

        if( !$result->status() ) { 
            say("\nCould not create ascend serialized entry with id: " . $_->id());
            my $substr = 'Duplicate entry';
            if (index($result->error, $substr) == -1) {
                return;
            } 
            say("\nIt is a duplicate. Let's update the serial of problem entry by post appending the new serialized id to it. ");
            updateProblemSerializedRecord($_);
            say("\nLet\'s try again...");
            $result = createAscendSerializedEntry($_);
            if( !$result->status() ) { 
                say("\nTried again but still could not create ascend serialized entry with id: " . $_->id());
                return;
            } else {
                 say("The second time was a charm!");
                 say("\nCreated ascend serialized Entry: " . $_->id());
            }

        } else {
            if ( !$quiet ) {
                say("\nCreated ascend serialized Entry: " . $_->id());
            }
        }
        #say Dumper($result);
    }
    $statement->finish;

}

sub updateProblemSerializedRecord {
    my $serializedModel = shift; # This is a serialized model
    my $newSerial = $serializedModel->serial . '-' . $serializedModel->id;
    my $statement1 = $elevenTestDB->prepare("update ascend_serialized set serial = ? where serial = ?");
    my $resultExecute = $statement1->execute($newSerial, $serializedModel->serial);
    $statement1->finish;
}

sub getMaxAscendSerializedId {
    my $statement = $elevenTestDB->prepare("select max(id) from ascend_serialized");
    my $resultExecute = $statement->execute();
    return $statement->fetchrow_hashref->{'max(id)'};
}


sub createAscendSerializedEntry {

	my $serializedModel = shift; # This is a serialized model
	my $model = buildAscendSerializedModel($serializedModel);
	my $result = MyModules::Bean::Result->new();

	my $statement = $elevenTestDB->prepare("insert into ascend_serialized values(?,?,?,?,?,?,?)");
	my $resultExecute = $statement->execute(
			$model->id(), 
			$model->serial(), 
			$model->productId(), 
			$model->itemDescription(), 			
			$model->customer(), 
			0,
			$model->lastModified() 
			# undef gets mapped to a null that is good.
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

sub getNewSerializedEntries {

    my $statement = shift;
    my @newEntries;
    while(my $ref = $statement->fetchrow_hashref)
    {
        my $model = MyModules::Bean::Serialized->new(
            id => $ref->{'id'},
            serial => $ref->{'serial'},
            description => $ref->{'description'},
            itemId => $ref->{'item_id'},
            customerId => $ref->{'customer_id'},
            lastModified => buildDatetime($ref->{'last_modified'})
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
		productId => getProductId($serializedModel->itemId()),
		itemDescription => $serializedModel->description(),
		customer => getCustomerName($serializedModel->customerId(),$serializedModel->saleLineId()),
		lastModified => $serializedModel->lastModified()
	);

	return $model;
}

sub getProductId {

	my $itemId = shift;
        my $productId;

        my $statement = $elevenProdDB->prepare("select id from product where lc_item_no=?");
        $statement->execute($itemId);
        my $ref2 = $statement->fetchrow_hashref;
        $productId =  $ref2->{'id'};
	return $productId;
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
