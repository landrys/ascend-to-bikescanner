DELIMITER //
CREATE  TRIGGER `populateIlsAcLastModified` BEFORE INSERT ON `item_location_scan_ac` 
FOR EACH ROW
BEGIN  
    SET NEW.last_modified := current_timestamp;
    END;
    //
DELIMITER ;
