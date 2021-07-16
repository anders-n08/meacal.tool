use regex::Regex;
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
struct Configuration {
    name: String,
    prefix: String,
    year: u32,
}

impl Configuration {
    fn load(name: &str) -> Option<Configuration> {
        let mut config_fp = dirs::home_dir().unwrap();
        config_fp.push(".config/meacal/meacal.config");

        let file = File::open(config_fp).unwrap();
        let config_lines = io::BufReader::new(file).lines();

        for maybe_line in config_lines {
            if let Ok(line) = maybe_line {
                let re =
                    Regex::new(&format!("{}!prefix:([a-zA-Z])\\|year:([0-9]{{4}})", name)).unwrap();
                let configuration = re.captures(&line).and_then(|cap| {
                    // todo: Is Option return type mandatory?
                    Some(Configuration {
                        name: name.to_string(),
                        prefix: cap
                            .get(1)
                            .map_or("".to_string(), |m| m.as_str().to_string()),
                        year: cap
                            .get(2)
                            .map_or(2000, |m| m.as_str().parse::<u32>().unwrap()),
                    })
                });

                if !configuration.is_none() {
                    return configuration;
                }
            }
        }

        None
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 3 {
        panic!("usage: {} prefix date", args[0]);
    }

    let configuration = Configuration::load(&args[1]);
    if let Some(cf) = configuration {
        let re = Regex::new(r"([0-9]{4})-([0-9]{2})-([0-9]{2})").unwrap();
        let cap = re.captures(&args[2]).unwrap();

        let year = cap[1].parse::<u32>().unwrap();
        let month = cap[2].parse::<u32>().unwrap();
        let day = cap[3].parse::<u32>().unwrap();

        let mea_cal_date =
            MeaCalDate::to_mea_cal_with_offset(cf.year, year, month, day, 0).unwrap();

        println!(
            "{}{:02}{}{:02}",
            cf.prefix, mea_cal_date.year, mea_cal_date.month, mea_cal_date.day
        );
    } else {
        panic!("{} not configured", args[1]);
    }
}
