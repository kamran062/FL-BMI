"""Builds assets/foods/foods.json, the offline food list used by Log food.

Each food: F(id, en, ur, portion, grams, kcal, protein, carbs, fat, aliases)

portion: a key of PORTIONS, or an (en, ur) tuple for counted items.
aliases: extra search words (Roman Urdu, common spellings).
Values are typical per-portion estimates for home/restaurant food in
Pakistan; they are shown in the app as approximate.

Run:  python3 tool/foods/build_foods.py
"""
import json, os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
OUT = os.path.join(ROOT, 'assets', 'foods', 'foods.json')

PORTIONS = {
    'medium': ('1 medium', '1 درمیانہ'),
    'piece': ('1 piece', '1 عدد'),
    'plate': ('1 plate', '1 پلیٹ'),
    'bowl': ('1 bowl', '1 پیالہ'),
    'cup': ('1 cup', '1 کپ'),
    'glass': ('1 glass', '1 گلاس'),
    'slice': ('1 slice', '1 سلائس'),
    'tbsp': ('1 tbsp', '1 کھانے کا چمچ'),
    'tsp': ('1 tsp', '1 چائے کا چمچ'),
    'scoop': ('1 scoop', '1 اسکوپ'),
    'can': ('1 can', '1 کین'),
    'handful': ('1 handful', '1 مٹھی'),
    'pack': ('1 pack', '1 پیکٹ'),
    'quarter': ('1 quarter', '1 چوتھائی'),
    'g100': ('100 g', '100 گرام'),
}


def F(id, en, ur, portion, grams, kcal, p, c, f, aliases=()):
    return dict(id=id, en=en, ur=ur, portion=portion, grams=grams, kcal=kcal,
                p=p, c=c, f=f, aliases=list(aliases))


FOODS = [
    # Breads
    F('roti', 'Roti (chapati)', 'روٹی (چپاتی)', 'medium', 40, 120, 4, 25, 0.6, ['chapati', 'phulka']),
    F('tandoori_roti', 'Tandoori roti', 'تندوری روٹی', 'piece', 60, 160, 5, 33, 1),
    F('paratha', 'Paratha', 'پراٹھا', 'piece', 80, 260, 5, 36, 11, ['parata']),
    F('aloo_paratha', 'Aloo paratha', 'آلو پراٹھا', 'piece', 120, 320, 7, 45, 13),
    F('anda_paratha', 'Egg paratha', 'انڈا پراٹھا', 'piece', 130, 380, 12, 38, 20, ['anda paratha']),
    F('naan', 'Naan', 'نان', 'piece', 90, 260, 8, 45, 5),
    F('roghni_naan', 'Roghni naan', 'روغنی نان', 'piece', 100, 320, 9, 48, 10),
    F('puri', 'Puri', 'پوری', 'piece', 30, 110, 2, 12, 6),
    F('white_bread', 'White bread', 'سفید ڈبل روٹی', 'slice', 28, 75, 2.5, 14, 1, ['double roti']),
    F('brown_bread', 'Brown bread', 'براؤن ڈبل روٹی', 'slice', 28, 70, 3.5, 12, 1),
    F('rusk', 'Rusk', 'رس', ('2 rusks', '2 رس'), 30, 125, 3.5, 21, 3),

    # Rice
    F('rice_white', 'Boiled white rice', 'ابلے سفید چاول', 'cup', 160, 205, 4, 45, 0.4, ['chawal', 'plain rice']),
    F('rice_brown', 'Brown rice', 'براؤن چاول', 'cup', 195, 215, 5, 45, 1.8, ['chawal']),
    F('chicken_biryani', 'Chicken biryani', 'چکن بریانی', 'plate', 300, 500, 25, 60, 18, ['biryani']),
    F('beef_biryani', 'Beef biryani', 'بیف بریانی', 'plate', 300, 540, 26, 60, 22, ['biryani']),
    F('chicken_pulao', 'Chicken pulao', 'چکن پلاؤ', 'plate', 300, 450, 22, 58, 14, ['pulao', 'yakhni pulao']),
    F('kabuli_pulao', 'Kabuli pulao', 'کابلی پلاؤ', 'plate', 300, 520, 22, 65, 19, ['pulao']),
    F('matar_pulao', 'Matar pulao', 'مٹر پلاؤ', 'plate', 250, 350, 8, 60, 9, ['pea rice', 'pulao']),
    F('khichdi', 'Khichdi', 'کھچڑی', 'bowl', 250, 300, 10, 50, 7),
    F('fried_rice', 'Egg fried rice', 'انڈا فرائیڈ رائس', 'plate', 250, 420, 10, 60, 15, ['chawal']),
    F('zarda', 'Zarda (sweet rice)', 'زردہ', 'bowl', 150, 330, 4, 60, 8, ['meethe chawal']),

    # Lentils and beans
    F('daal_masoor', 'Masoor daal', 'مسور کی دال', 'bowl', 200, 230, 12, 30, 7, ['dal', 'lentils']),
    F('daal_chana', 'Chana daal', 'چنے کی دال', 'bowl', 200, 280, 14, 36, 9, ['dal']),
    F('daal_mash', 'Mash daal', 'ماش کی دال', 'bowl', 200, 260, 13, 30, 10, ['dal', 'urad']),
    F('daal_moong', 'Moong daal', 'مونگ کی دال', 'bowl', 200, 220, 12, 30, 6, ['dal']),
    F('cholay', 'Chana masala (cholay)', 'چنے (چھولے)', 'bowl', 200, 300, 12, 40, 10, ['chickpeas', 'chole', 'chanay']),
    F('rajma', 'Rajma (kidney beans)', 'راجما', 'bowl', 200, 280, 13, 38, 8, ['lobia']),
    F('lobia', 'Lobia (black-eyed beans)', 'لوبیا', 'bowl', 200, 250, 13, 34, 7),
    F('haleem', 'Haleem', 'حلیم', 'bowl', 250, 400, 25, 35, 18, ['daleem']),
    F('daal_gosht', 'Daal gosht', 'دال گوشت', 'bowl', 250, 380, 26, 25, 20),

    # Meat curries
    F('chicken_karahi', 'Chicken karahi', 'چکن کڑاہی', 'bowl', 200, 380, 30, 8, 25, ['karahi']),
    F('mutton_karahi', 'Mutton karahi', 'مٹن کڑاہی', 'bowl', 200, 450, 30, 6, 34, ['karahi', 'gosht']),
    F('chicken_curry', 'Chicken curry (salan)', 'چکن سالن', 'bowl', 200, 300, 25, 8, 19, ['murgh', 'salan']),
    F('chicken_handi', 'Chicken handi', 'چکن ہانڈی', 'bowl', 200, 400, 28, 8, 28),
    F('chicken_jalfrezi', 'Chicken jalfrezi', 'چکن جلفریزی', 'bowl', 200, 320, 28, 10, 19),
    F('butter_chicken', 'Butter chicken', 'بٹر چکن', 'bowl', 200, 430, 28, 12, 30),
    F('chicken_korma', 'Chicken korma', 'چکن قورمہ', 'bowl', 200, 420, 26, 10, 31, ['qorma']),
    F('mutton_korma', 'Mutton korma', 'مٹن قورمہ', 'bowl', 200, 480, 28, 10, 36, ['qorma', 'gosht']),
    F('nihari', 'Beef nihari', 'نہاری', 'bowl', 250, 500, 32, 12, 36),
    F('qeema', 'Qeema', 'قیمہ', 'bowl', 200, 400, 26, 8, 29, ['keema', 'mince']),
    F('aloo_qeema', 'Aloo qeema', 'آلو قیمہ', 'bowl', 200, 330, 18, 18, 21, ['keema']),
    F('aloo_gosht', 'Aloo gosht', 'آلو گوشت', 'bowl', 250, 380, 24, 20, 22),
    F('palak_gosht', 'Palak gosht', 'پالک گوشت', 'bowl', 250, 350, 26, 10, 23),
    F('paya', 'Paya', 'پائے', 'bowl', 250, 380, 28, 5, 28, ['siri paye']),
    F('fish_curry', 'Fish curry', 'مچھلی کا سالن', 'bowl', 200, 280, 26, 6, 17, ['machli']),
    F('egg_curry', 'Egg curry (2 eggs)', 'انڈا کری (2 انڈے)', 'bowl', 200, 300, 14, 8, 24, ['anda curry']),
    F('chicken_manchurian', 'Chicken manchurian', 'چکن منچورین', 'bowl', 200, 380, 24, 20, 22),
    F('yakhni', 'Chicken yakhni (broth)', 'یخنی', 'bowl', 250, 60, 6, 2, 3, ['soup']),

    # Grills and BBQ
    F('chicken_tikka', 'Chicken tikka (leg piece)', 'چکن تکہ', 'piece', 150, 260, 32, 3, 13, ['bbq']),
    F('tandoori_chicken', 'Tandoori chicken', 'تندوری چکن', 'quarter', 200, 330, 40, 4, 17),
    F('malai_boti', 'Malai boti', 'ملائی بوٹی', ('6 pieces', '6 بوٹیاں'), 150, 330, 30, 3, 22, ['bbq']),
    F('seekh_kebab', 'Seekh kebab', 'سیخ کباب', 'piece', 50, 140, 9, 2, 11, ['kabab']),
    F('shami_kebab', 'Shami kebab', 'شامی کباب', 'piece', 50, 130, 8, 7, 8, ['kabab']),
    F('chapli_kebab', 'Chapli kebab', 'چپلی کباب', 'piece', 100, 300, 17, 8, 22, ['kabab']),
    F('sajji', 'Chicken sajji', 'سجی', 'quarter', 250, 450, 45, 5, 28),
    F('shawarma', 'Chicken shawarma', 'چکن شوارما', 'piece', 250, 550, 30, 55, 23),
    F('roll_paratha', 'Chicken roll paratha', 'رول پراٹھا', 'piece', 200, 500, 22, 45, 26, ['paratha roll']),

    # Plain meat, fish and eggs
    F('chicken_breast', 'Chicken breast (cooked)', 'چکن بریسٹ (پکی ہوئی)', 'g100', 100, 165, 31, 0, 3.6, ['murgh']),
    F('chicken_thigh', 'Chicken thigh (cooked)', 'چکن ران (پکی ہوئی)', 'g100', 100, 210, 26, 0, 11, ['murgh']),
    F('beef_lean', 'Lean beef (cooked)', 'بیف (پکا ہوا)', 'g100', 100, 220, 27, 0, 12, ['gosht', 'gaye']),
    F('mutton', 'Mutton (cooked)', 'مٹن (پکا ہوا)', 'g100', 100, 260, 25, 0, 17, ['gosht', 'bakra']),
    F('fish_grilled', 'Grilled fish', 'گرل مچھلی', 'g100', 100, 150, 22, 0, 6.5, ['machli']),
    F('fried_fish', 'Fried fish', 'فرائیڈ مچھلی', 'plate', 150, 380, 25, 18, 23, ['machli', 'lahori fish']),
    F('tuna', 'Tuna in water', 'ٹونا (پانی میں)', 'g100', 100, 116, 26, 0, 1),
    F('prawns', 'Prawns (cooked)', 'جھینگے', 'g100', 100, 99, 22, 0, 1.4, ['shrimp']),
    F('kaleji', 'Liver (kaleji), fried', 'کلیجی', 'g100', 100, 190, 24, 5, 8, ['liver']),
    F('nuggets', 'Chicken nuggets', 'چکن نگٹس', ('6 pieces', '6 عدد'), 100, 290, 15, 17, 18),
    F('egg_boiled', 'Boiled egg', 'ابلا ہوا انڈا', 'piece', 50, 78, 6.3, 0.6, 5.3, ['anda']),
    F('egg_fried', 'Fried egg', 'تلا ہوا انڈا', 'piece', 46, 90, 6, 0.4, 7, ['anda']),
    F('omelette', 'Omelette (2 eggs)', 'آملیٹ (2 انڈے)', 'piece', 120, 200, 13, 2, 15.5, ['anda', 'omelet']),
    F('egg_white', 'Egg white', 'انڈے کی سفیدی', 'piece', 33, 17, 3.6, 0.2, 0.1, ['anda']),

    # Vegetables and sides
    F('aloo_sabzi', 'Aloo sabzi', 'آلو کی سبزی', 'bowl', 150, 200, 3, 25, 10, ['potato', 'aloo bhujia']),
    F('bhindi', 'Bhindi (okra)', 'بھنڈی', 'bowl', 150, 160, 3, 12, 11, ['okra']),
    F('mixed_sabzi', 'Mixed vegetables', 'مکس سبزی', 'bowl', 150, 150, 4, 14, 9, ['sabzi']),
    F('palak', 'Palak (spinach)', 'پالک', 'bowl', 150, 160, 5, 10, 11, ['spinach', 'saag']),
    F('aloo_gobi', 'Aloo gobi', 'آلو گوبھی', 'bowl', 150, 170, 4, 18, 9, ['cauliflower']),
    F('baingan', 'Baingan bharta', 'بینگن کا بھرتہ', 'bowl', 150, 150, 3, 12, 10, ['eggplant', 'brinjal']),
    F('saag', 'Sarson ka saag', 'سرسوں کا ساگ', 'bowl', 200, 220, 6, 14, 16, ['saag']),
    F('lauki', 'Lauki (bottle gourd)', 'لوکی (گھیا)', 'bowl', 150, 100, 2, 8, 7, ['ghiya', 'kaddu']),
    F('salad', 'Green salad', 'سبز سلاد', 'bowl', 100, 20, 1, 4, 0.2, ['salad']),
    F('kachumber', 'Kachumber salad', 'کچومر سلاد', 'bowl', 100, 25, 1, 5, 0.2, ['salad']),
    F('raita', 'Raita', 'رائتہ', 'bowl', 100, 70, 3.5, 6, 3.5),
    F('potato_boiled', 'Boiled potato', 'ابلا ہوا آلو', 'medium', 150, 130, 3, 30, 0.2, ['aloo']),
    F('sweet_potato', 'Sweet potato (boiled)', 'شکرقندی', 'medium', 130, 112, 2, 26, 0.1, ['shakarkandi']),
    F('bhutta', 'Corn on the cob', 'بھٹا', 'piece', 100, 105, 3.4, 21, 1.5, ['corn', 'makai']),
    F('hummus', 'Hummus', 'حمص', ('2 tbsp', '2 کھانے کے چمچ'), 30, 75, 2.4, 4.3, 5.4),

    # Snacks and street food
    F('samosa', 'Samosa (aloo)', 'آلو سموسہ', 'piece', 80, 260, 4, 28, 15),
    F('samosa_qeema', 'Samosa (qeema)', 'قیمہ سموسہ', 'piece', 80, 280, 8, 24, 17, ['keema']),
    F('pakora', 'Pakoras', 'پکوڑے', ('5 pieces', '5 عدد'), 100, 300, 7, 28, 18, ['pakoray', 'bhajia']),
    F('kachori', 'Kachori', 'کچوری', 'piece', 60, 230, 5, 24, 13),
    F('spring_roll', 'Spring roll', 'اسپرنگ رول', 'piece', 60, 150, 4, 15, 8),
    F('dahi_bhallay', 'Dahi bhallay', 'دہی بھلے', 'plate', 200, 280, 8, 42, 9, ['dahi baray']),
    F('chana_chaat', 'Chana chaat', 'چنا چاٹ', 'plate', 200, 250, 10, 38, 7, ['chaat']),
    F('fruit_chaat', 'Fruit chaat', 'فروٹ چاٹ', 'plate', 200, 140, 1.5, 34, 0.5, ['chaat']),
    F('gol_gappay', 'Gol gappay', 'گول گپے', ('6 pieces', '6 عدد'), 120, 200, 4, 32, 6, ['pani puri']),
    F('bun_kebab', 'Bun kebab', 'بن کباب', 'piece', 180, 420, 15, 45, 20),
    F('nimko', 'Nimko (mixture)', 'نمکو', 'handful', 30, 160, 4, 14, 10, ['namkeen']),
    F('chips', 'Potato chips', 'چپس', 'pack', 30, 160, 2, 15, 10, ['crisps']),
    F('popcorn', 'Popcorn (plain)', 'پاپ کارن', 'cup', 8, 31, 1, 6, 0.4),
    F('biscuits', 'Biscuits', 'بسکٹ', ('3 biscuits', '3 بسکٹ'), 30, 140, 2, 21, 5.5, ['cookies']),
    F('nan_khatai', 'Nan khatai', 'نان خطائی', 'piece', 25, 130, 1.5, 14, 7.5),
    F('bhunay_chanay', 'Roasted chickpeas', 'بھنے ہوئے چنے', 'handful', 30, 110, 6, 17, 2, ['bhunay chanay', 'chana']),
    F('macaroni', 'Macaroni (desi style)', 'میکرونی', 'plate', 250, 400, 12, 55, 14, ['pasta']),
    F('chow_mein', 'Chicken chow mein', 'چکن چاؤمین', 'plate', 300, 480, 20, 55, 20, ['noodles']),
    F('instant_noodles', 'Instant noodles', 'انسٹنٹ نوڈلز', 'pack', 75, 350, 7, 48, 14, ['noodles']),
    F('corn_soup', 'Chicken corn soup', 'چکن کارن سوپ', 'bowl', 250, 180, 10, 22, 5.5, ['soup']),
    F('hot_sour_soup', 'Hot and sour soup', 'ہاٹ اینڈ ساور سوپ', 'bowl', 250, 150, 8, 18, 5, ['soup']),
    F('idli', 'Idli', 'اڈلی', ('2 pieces', '2 عدد'), 80, 120, 4, 25, 0.5),
    F('masala_dosa', 'Masala dosa', 'مسالہ ڈوسا', 'piece', 150, 350, 7, 48, 14, ['dosa']),

    # Fast food
    F('zinger', 'Zinger burger', 'زنگر برگر', 'piece', 220, 560, 26, 50, 28, ['burger']),
    F('beef_burger', 'Beef burger', 'بیف برگر', 'piece', 200, 520, 27, 40, 27, ['burger']),
    F('pizza', 'Pizza', 'پیزا', 'slice', 110, 290, 12, 33, 12),
    F('fries', 'French fries (medium)', 'فرنچ فرائز', 'pack', 110, 340, 4, 44, 16, ['chips']),
    F('fried_chicken', 'Fried chicken', 'فرائیڈ چکن', 'piece', 120, 320, 22, 10, 21),
    F('broast', 'Chicken broast', 'چکن بروسٹ', 'quarter', 250, 650, 38, 25, 44),
    F('club_sandwich', 'Club sandwich', 'کلب سینڈوچ', 'plate', 250, 550, 28, 45, 28, ['sandwich']),
    F('chicken_sandwich', 'Chicken sandwich', 'چکن سینڈوچ', 'piece', 150, 320, 18, 32, 13, ['sandwich']),
    F('chicken_wrap', 'Chicken wrap', 'چکن ریپ', 'piece', 220, 480, 25, 45, 21),
    F('pasta_white', 'Pasta in white sauce', 'وائٹ ساس پاستا', 'plate', 300, 600, 22, 65, 28, ['pasta']),

    # Breakfast and spreads
    F('halwa_puri', 'Halwa puri breakfast', 'حلوہ پوری ناشتہ', ('2 puri + halwa + cholay', '2 پوری + حلوہ + چنے'), 350, 900, 18, 105, 45, ['nashta']),
    F('oats_milk', 'Oats with milk', 'دودھ میں دلیہ', 'bowl', 250, 250, 10, 38, 6.5, ['oatmeal', 'daliya', 'porridge']),
    F('oats_dry', 'Oats (dry)', 'جئی (خشک)', ('½ cup', '½ کپ'), 40, 150, 5, 27, 2.7, ['oatmeal']),
    F('cornflakes', 'Cornflakes with milk', 'کارن فلیکس دودھ کے ساتھ', 'bowl', 180, 200, 7, 34, 4.5, ['cereal']),
    F('peanut_butter', 'Peanut butter', 'پینٹ بٹر', 'tbsp', 16, 95, 3.5, 3.5, 8),
    F('butter', 'Butter', 'مکھن', 'tsp', 5, 36, 0, 0, 4, ['makhan']),
    F('jam', 'Jam', 'جام', 'tbsp', 20, 55, 0, 14, 0),
    F('honey', 'Honey', 'شہد', 'tbsp', 21, 64, 0, 17, 0, ['shehad']),
    F('cheese_slice', 'Cheese slice', 'چیز سلائس', 'slice', 20, 65, 4, 1, 5, ['cheese']),
    F('paneer', 'Paneer', 'پنیر', 'g100', 100, 300, 18, 4, 23, ['cottage cheese']),

    # Dairy and drinks
    F('milk_whole', 'Milk (full cream)', 'دودھ', 'glass', 250, 160, 8, 12, 8.5, ['doodh']),
    F('milk_lowfat', 'Milk (low fat)', 'کم چکنائی والا دودھ', 'glass', 250, 110, 8.5, 12.5, 2.5, ['doodh']),
    F('yogurt', 'Yogurt (dahi)', 'دہی', 'cup', 200, 120, 7, 9, 6.5, ['dahi', 'curd']),
    F('greek_yogurt', 'Greek yogurt (plain)', 'یونانی دہی', 'cup', 170, 100, 17, 6, 0.7, ['dahi']),
    F('lassi_sweet', 'Sweet lassi', 'میٹھی لسی', 'glass', 300, 250, 8, 38, 7),
    F('lassi_salty', 'Salty lassi', 'نمکین لسی', 'glass', 300, 140, 7, 10, 8),
    F('chai', 'Doodh patti chai (with sugar)', 'دودھ پتی چائے (چینی کے ساتھ)', 'cup', 200, 110, 3.5, 15, 4, ['tea', 'chay']),
    F('chai_no_sugar', 'Tea with milk (no sugar)', 'چائے (بغیر چینی)', 'cup', 150, 40, 1.5, 3, 2, ['tea', 'chay']),
    F('green_tea', 'Green tea', 'سبز چائے', 'cup', 240, 2, 0, 0.5, 0, ['qehwa', 'kahwa']),
    F('black_coffee', 'Black coffee', 'بلیک کافی', 'cup', 240, 2, 0.3, 0, 0, ['coffee']),
    F('cappuccino', 'Cappuccino', 'کیپوچینو', 'cup', 240, 120, 6, 10, 6, ['coffee']),
    F('soft_drink', 'Soft drink', 'کولڈ ڈرنک', 'can', 330, 140, 0, 35, 0, ['cola', 'coke', 'pepsi', 'cold drink']),
    F('energy_drink', 'Energy drink', 'انرجی ڈرنک', 'can', 250, 110, 0, 28, 0),
    F('orange_juice', 'Fresh orange juice', 'مالٹے کا جوس', 'glass', 250, 112, 1.7, 26, 0.5, ['juice', 'kinnow']),
    F('sugarcane_juice', 'Sugarcane juice', 'گنے کا رس', 'glass', 250, 180, 0, 45, 0, ['ganna']),
    F('mango_shake', 'Mango shake', 'آم کا شیک', 'glass', 300, 300, 8, 50, 7.5, ['milkshake']),
    F('banana_shake', 'Banana shake', 'کیلے کا شیک', 'glass', 300, 280, 9, 45, 7, ['milkshake']),
    F('rooh_afza_milk', 'Rooh Afza with milk', 'روح افزا دودھ', 'glass', 250, 230, 8, 33, 7.5, ['doodh']),
    F('nimbu_pani', 'Lemonade (nimbu pani)', 'لیموں پانی', 'glass', 250, 80, 0, 20, 0, ['shikanjbeen']),
    F('whey', 'Whey protein', 'وے پروٹین', 'scoop', 30, 120, 24, 3, 1.5, ['protein shake']),
    F('protein_bar', 'Protein bar', 'پروٹین بار', 'piece', 60, 220, 20, 22, 7),
    F('granola_bar', 'Granola bar', 'گرینولا بار', 'piece', 35, 150, 3, 24, 5),

    # Sweets
    F('gulab_jamun', 'Gulab jamun', 'گلاب جامن', 'piece', 40, 150, 2, 22, 6),
    F('jalebi', 'Jalebi', 'جلیبی', ('50 g', '50 گرام'), 50, 200, 1.5, 30, 8),
    F('kheer', 'Kheer', 'کھیر', 'bowl', 150, 220, 6, 32, 7.5),
    F('gajar_halwa', 'Gajar ka halwa', 'گاجر کا حلوہ', ('½ cup', '½ کپ'), 100, 280, 5, 35, 14, ['halwa']),
    F('suji_halwa', 'Suji halwa', 'سوجی کا حلوہ', ('½ cup', '½ کپ'), 100, 330, 4, 42, 16, ['halwa']),
    F('barfi', 'Barfi', 'برفی', 'piece', 30, 130, 3, 16, 6, ['mithai']),
    F('laddu', 'Laddu', 'لڈو', 'piece', 40, 180, 3, 22, 9, ['mithai']),
    F('ras_malai', 'Ras malai', 'رس ملائی', ('2 pieces', '2 عدد'), 100, 220, 8, 26, 9.5, ['mithai']),
    F('sheer_khurma', 'Sheer khurma', 'شیر خرمہ', 'bowl', 200, 350, 9, 45, 15),
    F('custard', 'Custard', 'کسٹرڈ', 'bowl', 150, 180, 5, 28, 5.5),
    F('kulfi', 'Kulfi', 'قلفی', 'piece', 70, 160, 4, 18, 8),
    F('falooda', 'Falooda', 'فالودہ', 'glass', 300, 400, 9, 60, 13),
    F('ice_cream', 'Ice cream', 'آئس کریم', 'scoop', 70, 140, 2.5, 16, 7.5),
    F('chocolate', 'Milk chocolate bar', 'چاکلیٹ', 'piece', 45, 240, 3, 26, 14),
    F('dark_chocolate', 'Dark chocolate', 'ڈارک چاکلیٹ', ('2 squares', '2 ٹکڑے'), 20, 120, 1.5, 9, 8.5),
    F('cake', 'Cake', 'کیک', 'slice', 80, 300, 4, 40, 14),

    # Fruit
    F('banana', 'Banana', 'کیلا', 'medium', 118, 105, 1.3, 27, 0.4, ['kela']),
    F('apple', 'Apple', 'سیب', 'medium', 180, 95, 0.5, 25, 0.3, ['saib', 'seb']),
    F('mango', 'Mango', 'آم', 'medium', 200, 120, 1.6, 30, 0.8, ['aam']),
    F('orange', 'Orange (kinnow)', 'کینو', 'medium', 130, 60, 1.2, 15, 0.2, ['kinnow', 'malta']),
    F('guava', 'Guava', 'امرود', 'medium', 100, 68, 2.6, 14, 1, ['amrood']),
    F('dates', 'Dates', 'کھجور', ('3 dates', '3 کھجوریں'), 24, 67, 0.6, 18, 0, ['khajoor']),
    F('grapes', 'Grapes', 'انگور', 'cup', 150, 104, 1, 27, 0.2, ['angoor']),
    F('watermelon', 'Watermelon', 'تربوز', 'cup', 150, 46, 0.9, 11.5, 0.2, ['tarbooz']),
    F('melon', 'Melon (kharbooza)', 'خربوزہ', 'cup', 160, 54, 1.3, 13, 0.3, ['kharbooza']),
    F('pomegranate', 'Pomegranate', 'انار', ('½ fruit', 'آدھا انار'), 140, 115, 2.3, 26, 1.6, ['anar']),
    F('papaya', 'Papaya', 'پپیتا', 'cup', 145, 62, 0.7, 16, 0.4, ['papita']),
    F('pear', 'Pear', 'ناشپاتی', 'medium', 180, 100, 0.6, 27, 0.2, ['nashpati']),
    F('peach', 'Peach', 'آڑو', 'medium', 150, 60, 1.4, 14, 0.4, ['aaru']),
    F('strawberries', 'Strawberries', 'اسٹرابیری', 'cup', 150, 48, 1, 11.5, 0.5),
    F('chikoo', 'Chikoo (sapodilla)', 'چیکو', 'medium', 100, 83, 0.4, 20, 1.1),
    F('dried_apricot', 'Dried apricots', 'خشک خوبانی', ('5 pieces', '5 عدد'), 35, 84, 1.2, 22, 0.2, ['khubani']),
    F('raisins', 'Raisins', 'کشمش', ('2 tbsp', '2 کھانے کے چمچ'), 20, 60, 0.6, 16, 0.1, ['kishmish']),

    # Nuts
    F('almonds', 'Almonds', 'بادام', ('10 almonds', '10 بادام'), 14, 82, 3, 3, 7, ['badam']),
    F('walnuts', 'Walnuts', 'اخروٹ', ('5 halves', '5 ٹکڑے'), 15, 98, 2.3, 2, 9.8, ['akhrot']),
    F('peanuts', 'Peanuts', 'مونگ پھلی', 'handful', 28, 160, 7, 4.5, 14, ['moongphali']),
    F('cashews', 'Cashews', 'کاجو', ('10 cashews', '10 کاجو'), 15, 85, 2.7, 4.5, 6.6, ['kaju']),
    F('pistachios', 'Pistachios', 'پستہ', ('20 pistachios', '20 پستے'), 15, 85, 3, 4, 7, ['pista']),
    F('mixed_nuts', 'Mixed dry fruit', 'مکس ڈرائی فروٹ', 'handful', 30, 170, 5, 7, 14, ['dry fruit', 'mewa']),

    # Cooking extras
    F('oil', 'Cooking oil', 'کوکنگ آئل', 'tbsp', 14, 124, 0, 0, 14, ['tel']),
    F('ghee', 'Desi ghee', 'دیسی گھی', 'tsp', 5, 45, 0, 0, 5),
    F('sugar', 'Sugar', 'چینی', 'tsp', 4, 16, 0, 4, 0, ['cheeni']),
    F('ketchup', 'Ketchup', 'کیچپ', 'tbsp', 17, 20, 0.2, 5, 0),
    F('mayonnaise', 'Mayonnaise', 'مایونیز', 'tbsp', 14, 95, 0.1, 0.1, 10.5, ['mayo']),
]


def check(foods):
    ids = set()
    for x in foods:
        assert x['id'] not in ids, f"duplicate id {x['id']}"
        ids.add(x['id'])
        assert x['en'].strip() and x['ur'].strip(), x['id']
        if isinstance(x['portion'], str):
            assert x['portion'] in PORTIONS, x['id']
        est = 4 * x['p'] + 4 * x['c'] + 9 * x['f']
        # kcal ≈ 4P + 4C + 9F (fibre makes fruit read a little high)
        if x['kcal'] >= 20:
            assert abs(est - x['kcal']) / x['kcal'] <= 0.15, (x['id'], x['kcal'], est)
        else:
            assert abs(est - x['kcal']) <= 5, x['id']


def build():
    check(FOODS)
    out = []
    for x in FOODS:
        p = x['portion']
        en, ur = PORTIONS[p] if isinstance(p, str) else p
        g = x['grams']
        label_en = en if p == 'g100' else f'{en} ({g} g)'
        label_ur = ur if p == 'g100' else f'{ur} ({g} گرام)'
        out.append(dict(
            id=x['id'], en=x['en'], ur=x['ur'],
            portionEn=label_en, portionUr=label_ur, grams=g, kcal=x['kcal'],
            protein=x['p'], carbs=x['c'], fat=x['f'],
            **({'aliases': x['aliases']} if x['aliases'] else {}),
        ))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump({'version': 1, 'foods': out}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(f'{len(out)} foods → {os.path.relpath(OUT, ROOT)}')


if __name__ == '__main__':
    build()
