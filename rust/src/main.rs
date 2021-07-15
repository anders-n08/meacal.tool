use std::char;
use std::env;
use std::fs::File;
use std::io::{self, BufRead};

#[derive(Debug)]
struct MeaCalDate {
    year: u32,
    month: char,
    day: u32,
}

impl MeaCalDate {
    fn is_leap_year(year: u32) -> bool {
        return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
    }

    fn to_mea_cal_with_offset(
        base_year: u32,
        year: u32,
        month: u32,
        day: u32,
        offset: u32,
    ) -> Option<MeaCalDate> {
        let mut number_of_days = match month {
            1 => 0,
            2 => 31,
            3 => 31 + 28,
            4 => 31 + 28 + 31,
            5 => 31 + 28 + 31 + 30,
            6 => 31 + 28 + 31 + 30 + 31,
            7 => 31 + 28 + 31 + 30 + 31 + 30,
            8 => 31 + 28 + 31 + 30 + 31 + 30 + 31,
            9 => 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31,
            10 => 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30,
            11 => 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31,
            12 => 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30,
            _ => panic!("invalid month"),
        };

        let mut adjusted_year = year;

        // magic number - 0 index
        number_of_days += day - 1 + offset;

        if number_of_days >= 365 {
            number_of_days -= 365;
            adjusted_year += 1;
        }

        let p1 = adjusted_year - base_year;
        let mut p2 = std::char::from_u32(65 + number_of_days / 14).unwrap();
        if p2 == '[' {
            p2 = '+';
        }
        let mut p3 = number_of_days % 14;

        if MeaCalDate::is_leap_year(adjusted_year) && (month == 2) && (day == 29) {
            p2 = '+';
            p3 = 1;
        }

        return Some(MeaCalDate {
            year: p1,
            month: p2,
            day: p3,
        });
    }
}

#[derive(Debug)]
struct ConfigItem {
    name: String,
    prefix: String,
    year: u32,
}

impl ConfigItem {
    fn create(name: &str, cfs: &str) -> Option<ConfigItem> {
        // fixme: A bit of a mess with Option, unwrap etc etc.

        let mut prefix: Option<&str> = None;
        let mut year: Option<u32> = None;
        let config_items: Vec<&str> = cfs.split("|").collect();
        for config_item in config_items {
            let v0: Vec<&str> = config_item.split(":").collect();
            if v0.len() != 2 {
                panic!("Invalid configuration item");
            }

            match v0[0] {
                "prefix" => prefix = Some(v0[1]),
                "year" => year = Some(v0[1].parse::<u32>().unwrap()),
                _ => panic!("Unknown config item {}", v0[0]),
            }
        }

        return Some(ConfigItem {
            name: name.to_string(),
            prefix: prefix?.to_string(),
            year: year?,
        });
    }
}

fn load_configuration(name: &str) -> Option<ConfigItem> {
    let mut config_fp = dirs::home_dir().unwrap();
    config_fp.push(".config/meacal/meacal.config");

    let file = File::open(config_fp).unwrap();
    let config_lines = io::BufReader::new(file).lines();

    for line in config_lines {
        if let Ok(ip) = line {
            let mut split = ip.split("!");
            let config_name = split.next();
            let config_str = split.next();
            match config_name {
                Some(n) if n == name => {
                    return ConfigItem::create(n, config_str?);
                }
                _ => {}
            }
        }
    }

    None
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 3 {
        println!("usage: {} prefix date", args[0]);
        return ();
    }

    let config_item = load_configuration(&args[1]);
    if let Some(cf) = config_item {
        println!("{:?}", cf);
        let date_items: Vec<&str> = args[2].split("-").collect();
        if date_items.len() != 3 {
            panic!("invalid date format");
        }

        let year = date_items[0].parse::<u32>().unwrap();
        let month = date_items[1].parse::<u32>().unwrap();
        let day = date_items[2].parse::<u32>().unwrap();

        let mea_cal_date =
            MeaCalDate::to_mea_cal_with_offset(cf.year, year, month, day, 0).unwrap();

        println!(
            "{}{}{}{}",
            cf.prefix, mea_cal_date.year, mea_cal_date.month, mea_cal_date.day
        );
    } else {
        panic!("{} not configured", args[1]);
    }
}
