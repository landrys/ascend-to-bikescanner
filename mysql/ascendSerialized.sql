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
-- Table structure for table `ascend_serialized`
--

DROP TABLE IF EXISTS `ascend_serialized`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ascend_serialized` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `serial` varchar(100) NOT NULL,
  `product` varchar(50) DEFAULT NULL,
  `item_description` varchar(350) DEFAULT NULL,
  `customer` varchar(100) DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',  
  `last_modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product` (`product`),
  CONSTRAINT `ascend_serialized_ibfk_1` FOREIGN KEY (`product`) REFERENCES `product` (`id`),
  UNIQUE KEY `serial` (`serial`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
