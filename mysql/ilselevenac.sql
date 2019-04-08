-- MySQL dump 10.13  Distrib 5.7.12, for osx10.11 (x86_64)
--
-- Host: localhost    Database: eleven
-- ------------------------------------------------------
-- Server version	5.7.12

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `item_location_scan_ac`
--

DROP TABLE IF EXISTS `item_location_scan_ac`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_location_scan_ac` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `serialized` bigint(20) NOT NULL,
  `scan_location` bigint(20) DEFAULT NULL,
  `destination_location` bigint(20) DEFAULT NULL,
  `employee` bigint(20) NOT NULL,
  `action` bigint(20) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_modified` datetime DEFAULT NULL,
  `done` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `serialized` (`serialized`),
  KEY `scan_location` (`scan_location`),
  KEY `destination_location` (`destination_location`),
  KEY `employee` (`employee`),
  KEY `action` (`action`),
  CONSTRAINT `item_location_scan_ac_ibfk_1` FOREIGN KEY (`serialized`) REFERENCES `ascend_serialized` (`id`),
  CONSTRAINT `item_location_scan_ac_ibfk_2` FOREIGN KEY (`scan_location`) REFERENCES `location` (`id`),
  CONSTRAINT `item_location_scan_ac_ibfk_3` FOREIGN KEY (`destination_location`) REFERENCES `location` (`id`),
  CONSTRAINT `item_location_scan_ac_ibfk_4` FOREIGN KEY (`employee`) REFERENCES `employee` (`id`),
  CONSTRAINT `item_location_scan_ac_ibfk_5` FOREIGN KEY (`action`) REFERENCES `action` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `populateIlsAcLastModified` BEFORE INSERT ON `item_location_scan_ac` FOR EACH ROW BEGIN
        SET NEW.last_modified := current_timestamp;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER latestILSac AFTER INSERT ON item_location_scan_ac
FOR EACH ROW
BEGIN
    IF new.serialized not in (
        select ls.serialized
        From latest_scan_ac ls
        where (ls.serialized = new.serialized )
        )
        THEN
        insert into latest_scan_ac(serialized, item_location_scan) values(new.serialized, new.id);

    ELSE   
        update latest_scan_ac set item_location_scan=new.id where serialized=new.serialized;
                                                                END IF;
                                                        END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-12-15 11:52:21
