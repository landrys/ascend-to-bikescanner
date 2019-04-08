-- MySQL dump 10.13  Distrib 5.5.31, for Linux (x86_64)
--
-- Host: localhost    Database: eleven 
-- ------------------------------------------------------
-- Server version	5.5.31-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES latin1 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `job`
--

DROP TABLE IF EXISTS `ascend_to_bikescanner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ascend_to_bikescanner` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `serial` varchar(100) DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `action_time` datetime DEFAULT NULL,
  `product_id` varchar(50) DEFAULT NULL,
  `lc_item_no` varchar(50) DEFAULT NULL,
  `item_description` varchar(200) DEFAULT NULL,
  `customer` varchar(100) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `destination_location_id` int(11) DEFAULT NULL,
  `user_email` varchar(50) NOT NULL,
  `password` varchar(50) DEFAULT NULL,
  `sku` varchar(50) DEFAULT NULL,
  `employee_name` varchar(50) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `size` varchar(100) DEFAULT NULL,
  `color` varchar(100) DEFAULT NULL,
  `model` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  `status` varchar(500) default null,
  `last_modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
