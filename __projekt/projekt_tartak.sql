
-- -----------------------------------------------------
-- Table `mydb`.`hala_tartaczna`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `hala_tartaczna` (
  `id_stanowiska` INT NOT NULL AUTO_INCREMENT,
  `nazwa` VARCHAR(45) NOT NULL,
  `liczba_osob` INT NOT NULL,
  `narzedzia` VARCHAR(45) NULL,
  PRIMARY KEY (`id_stanowiska`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`pracownik`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pracownik` (
  `id_pracownika` INT NOT NULL AUTO_INCREMENT,
  `id_stanowiska` INT NOT NULL,
  `imie` VARCHAR(45) NOT NULL,
  `nazwisko` VARCHAR(45) NOT NULL,
  `pensja` FLOAT(7,2) NOT NULL,
  `pesel` VARCHAR(11) NOT NULL,
  `telefon` VARCHAR(9) NOT NULL,
  `wyksztalcenie` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_pracownika`),
  INDEX `fk_pracownik_hala_tartaczna1_idx` (`id_stanowiska` ASC) VISIBLE,
  CONSTRAINT `fk_pracownik_hala_tartaczna1`
    FOREIGN KEY (`id_stanowiska`)
    REFERENCES `hala_tartaczna` (`id_stanowiska`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`klient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `klient` (
  `id_klienta` INT NOT NULL AUTO_INCREMENT,
  `imie` VARCHAR(45) NOT NULL,
  `nazwisko` VARCHAR(45) NOT NULL,
  `nr_tel` VARCHAR(9) NOT NULL,
  `firma` VARCHAR(3) NULL,
  `NIP` VARCHAR(10) NULL,
  PRIMARY KEY (`id_klienta`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`zamowienia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zamowienia` (
  `id_zamowienia` INT NOT NULL AUTO_INCREMENT,
  `data_zamowienia` DATE NOT NULL,
  `numer_zamowienia` VARCHAR(255) NOT NULL,
  `cena` FLOAT NOT NULL,
  `id_klienta` INT NOT NULL,
  `id_pracownika` INT NOT NULL,
  PRIMARY KEY (`id_zamowienia`),
  INDEX `fk_zamowienia_klient1_idx` (`id_klienta` ASC) VISIBLE,
  INDEX `fk_zamowienia_pracownik1_idx` (`id_pracownika` ASC) VISIBLE,
  CONSTRAINT `fk_zamowienia_klient1`
    FOREIGN KEY (`id_klienta`)
    REFERENCES `klient` (`id_klienta`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_zamowienia_pracownik1`
    FOREIGN KEY (`id_pracownika`)
    REFERENCES `pracownik` (`id_pracownika`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`sklad_surowca`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sklad_surowca` (
  `id_drewna` INT NOT NULL AUTO_INCREMENT,
  `rodzaj` VARCHAR(45) NOT NULL,
  `ilosc` FLOAT(7,2) NOT NULL,
  `pochodzenie` VARCHAR(45) NOT NULL,
  `jakosc` VARCHAR(45) NOT NULL,
  `id_pracownika` INT NOT NULL,
  `id_klienta` INT NULL,
  PRIMARY KEY (`id_drewna`),
  INDEX `fk_magazyn_pracownik1_idx` (`id_pracownika` ASC) VISIBLE,
  INDEX `fk_magazyn_klient1_idx` (`id_klienta` ASC) VISIBLE,
  CONSTRAINT `fk_magazyn_pracownik1`
    FOREIGN KEY (`id_pracownika`)
    REFERENCES `pracownik` (`id_pracownika`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_magazyn_klient1`
    FOREIGN KEY (`id_klienta`)
    REFERENCES `klient` (`id_klienta`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`adres_klienta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `adres_klienta` (
  `id_klienta` INT NOT NULL,
  `ulica` VARCHAR(255) NOT NULL,
  `kod_pocztowy` VARCHAR(6) NOT NULL,
  `miejscowosc` VARCHAR(45) NULL,
  PRIMARY KEY (`id_klienta`),
  INDEX `fk_adres_klienta_klient_idx` (`id_klienta` ASC) VISIBLE,
  CONSTRAINT `fk_adres_klienta_klient`
    FOREIGN KEY (`id_klienta`)
    REFERENCES `klient` (`id_klienta`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`status_zamowienia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `status_zamowienia` (
  `id_zamowienia` INT NOT NULL,
  `nazwa_statusu_zamowienia` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_zamowienia`),
  INDEX `fk_status_zamowienia_zamowienia1_idx` (`id_zamowienia` ASC) VISIBLE,
  CONSTRAINT `fk_status_zamowienia_zamowienia1`
    FOREIGN KEY (`id_zamowienia`)
    REFERENCES `zamowienia` (`id_zamowienia`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`wydatki`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `wydatki` (
  `id_wydatku` INT NOT NULL AUTO_INCREMENT,
  `id_pracownika` INT NOT NULL,
  `nazwa` VARCHAR(45) NOT NULL,
  `cena` FLOAT NOT NULL,
  `data` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_wydatku`),
  INDEX `fk_wydatki_pracownik1_idx` (`id_pracownika` ASC) VISIBLE,
  CONSTRAINT `fk_wydatki_pracownik1`
    FOREIGN KEY (`id_pracownika`)
    REFERENCES `pracownik` (`id_pracownika`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

DELIMITER //
create procedure premia(IN id int)
BEGIN
Update pracownik set pensja = 1.1 * pensja where id_pracownika = id;
END
//
DELIMITER ;

DELIMITER //
create function zamien_pesel_na_date(pesel char(11)) returns char(10)
BEGIN
declare rok char(4);
declare mies char(2);
declare dzien char(2);
set dzien = substr(pesel,5,2);
set mies = substr(pesel,3,2);
set rok = concat('19',substr(pesel,1,2));
return concat(rok,'-',mies,'-',dzien);
END
//
DELIMITER ;

DELIMITER //
create trigger pensja_before_insert
before insert on pracownik
for each row
begin
if new.pensja<2600
then
set new.pensja=2600;
end if;
end //
DELIMITER ;

DELIMITER //
create trigger odpowiednie_wyksztalcenie before insert on pracownik
for each row
begin
if new.wyksztalcenie!='podstawowe' and new.wyksztalcenie!='srednie' and new.wyksztalcenie!='wyzsze'
then
signal sqlstate '45000' set message_text = 'Brak odpowiedniego wyksztalcenia pracownika. Nie zatrudniac.';
end if;
end //
DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
