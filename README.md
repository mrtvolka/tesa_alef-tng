# Inštalačná príručka - TESATEAM
verzia: 1.0<br>
zostavené: 13.5.2016<br>
vypracoval: Lukáš Csóka, xcsokal@stuba.sk

# Úvod
Táto príručka udáva podmienky a spôsob inštalácie systému TESA - Priebežné overovanie prípravy študentov na cvičeniach. Tento systém je založený na open-source riešení Alef-tng (https://github.com/PewePro/alef-tng).
Kompletné zdrojové kódy sú dostupné tu: https://github.com/tesa/tesa_alef-tng vo vetve osicky_develop.

# Podmienky inštalácie
TESA nie je náročná na výpočtový výkon, vyžaduje ale splnenie viacerých podmienok na funkčný beh:

 - Minimálne virtuálny server (2GB operačnej pamäte, 10GB diskového miesta, 2 virtualizované jadrá)
 - Server má operačný systém Ubuntu Server 14.04.4 LTS alebo obdobný operačný systém
 - Na serveri je nainštalovaný PostgreSQL vo verzii 9.3.11 (presne táto verzia je nutná)
 - Na serveri je nainštalovaný Apache2 (otestované s verziou 2.4.7) (ak sa použije iný webserver, treba upraviť konfiguráciu pre nainštalovaný webserver)
 - TCP port 80 a 443 sú voľné a prístupné (respektíve využívané v Apache2)
 - Na inštaláciu je nutné mať užívateľa s právami root

# Postup inštalácie
Jeden server je možné používať na viacero predmetov, pričom ale na každý predmet je vždy nutná vlastná inštancia – vlastný zdrojový kód, vlastná databáza. V tomto návode budeme predpokladať inštaláciu WebTestu tak, aby súčasne bežalo viacero inštancií, pričom každá inštancia beží na vlastnej sub-uri adrese k `root` doméne, napríklad pre predmet AZA beží inštancia na doméne `tesa.fiit.stuba.sk/aza`.

Každá inštancia by mala mať vlastného vytvoreného používateľa. Pre ukážky inštalácie predpokladáme používateľa `user_aza` s domovským priečinkom `/home/user_aza`.

Najprv je udávaný postup inštalácie len pre TESA, následne aj voliteľná integrácia s webserverom Apache2, vrátane inštalácie passengera. Následne príprava databázy, príklady konfiguračných súborov a časté chyby.

## Inštalácia inštancie TESA
1. Nainštalovať RUBY VERSION MANAGER (RVM)  -  https://rvm.io . V čase tvorby tejto príručky (13.5.2016) sa RVM inštaloval v domovskom adresári užívateľa pomocou príkazov:

        gpg --keyserver hkp://keys.gnupg.net --recv-keys \
        409B6B1796C275462A1703113804BB82D39DC0E3
        \curl -sSL https://get.rvm.io | bash -s stable

2. Zmeniť RUBY verziu na 2.2.0 pomocou príkazov:

        rvm install 2.2.0
        rvm --default 2.2.0

3.	Do zvoleného priečinka, napríklad v našom prípade `/home/user_aza/aza` nahrať zdrojový kód aplikácie. Napríklad v domovskom adresári pomocou príkazu:

        git clone -b osicky_develop https://git@github.com/mrtvolka/tesa_alef-tng.git aza

4.	Vytvoriť databázového používateľa, ktorý má právo vytvárať databázy (privilégium `CREATEDB`).
5.	V zdrojovom kóde skopírovať a upraviť súbor `/home/user_aza/aza/config/database.yml.example`. Je nutné upraviť minimálne názov produkčnej databázy, aby mala každá inštancia jedinečný názov databázy a prihlasovacie údaje. Príklad úpravy je v časti ukážok konfiguračných súborov.

        cp /home/user_aza/aza/database.yml.example /home/user_aza/aza/database.yml
        
        nano database.yml

6.	Do `/home/user_aza/aza/config/application.rb` pridať riadok: 

        config.relative_url_root = "/XXXX"

    ,kde `XXXX` značí sub-uri. V našom prípade to bude vyzarať takto:

        config.relative_url_root = "/aza"

7. V `/home/user_aza/aza/config/enviroments/production` upraviť smtp spojenie v časti súboru označenom ako `#Mail`. Príklad úpravy je v časti konfiguračných súborov.
8. V adresári zdrojového kódu `/home/user_aza/aza` spustiť príkaz `gem install bundler` na nainštalovanie bundler - rails utility na manažovanie rails gemov.
9. V adresári zdrojového kódu `/home/user_aza/aza` spustiť príkaz `bundle install` na nainštalovanie všetkých potrebných rails gemov (gemy sú definované v `/home/user_aza-aza/Gemfile`).
10. Spustiť príkaz `rake assets:precompile` v adresáry zdrojového kódu - v našom prípade `/home/user_aza/aza`.
11. (Voliteľné) TESA podporuje LDAP na prihlasovanie užívateľov, pričom im pridá aj práva podľa nastavenia v LDAP, respektíve AIS. Je nutné upraviť súbor `/home/user_aza/aza/config/ldap.yml`. Príklad úpravy je v časti ukážok konfiguračných súborov.

## Integrácia s Apache2
Pre integráciu s Apache2 sa predpokladá prístup len cez https. Tiež sa predpokladá `DocumentRoot` nastavený na `/www/data/`.

1. Doinštalovať knižnice, ak chýbajú:

        apt-get install libcurl4-openssl-dev
        apt-get install apache2-threaded-dev

2. Nainštalovať Passenger.

        gem install passenger

    a zvoliť Ruby a následne postupovať podľa inštrukcií.

2. Do `/etc/apache2/mods-available/passenger.conf` 
a `/etc/apache2/mods-available/passenger.load` doplniť: 

        LoadModule passenger_module <<CESTA K RUBY>>@aleftng/gems/passenger-5.0.21/buildout/apache2/mod_passenger.so
        <IfModule mod_passenger.c>
        PassengerRoot <<CESTA K RUBY>>@aleftng/gems/passenger-5.0.21
        PassengerDefaultRuby <<CESTA K RUBY>>@aleftng/wrappers/ruby
        </IfModule>

    Výraz `<<CESTA K RUBY>>` nahradiť cestou k ruby, cesta môže vyzerať takto `/home/user_aza/.rvm/gems/ruby-2.2.0`. Ako je vidno z časti `passenger-5.0.21`, Passenger bol nainštalovaný vo verzii 5.0.21, ktorý bol v čase našej inštalácie posledná stabilná verzia. Môže byť nutné zmeniť verziu. Verziu Passengera je možné zistiť príkazom `passenger -v`. 

3. Do `/etc/apache2/sites-enabled/000-default.conf` doplniť:

        RewriteCond %{HTTPS} !=on
        RewriteRule ^/aza(.*) https://webtest.sk/aza$1 [R,L]
        Alias /aza /var/www/aza/public

    a uistiť sa, že `RewriteEngine` je nastavený na `On`.

4. Do `/etc/apache2/sites-enabled/default-ssl.conf` doplniť:

        Alias /aza /var/www/aza/public
        <Location /aza>
            PassengerBaseURI /aza
            PassengerAppRoot /var/www/aza
            PassengerResolveSymlinksInDocumentRoot on
            SetEnv ALEFTNG_SECRET_KEY_BASE <<SECRET>>
        </Location>
        
        <Directory /var/www/aza/public>
        	AllowOverride all
        	Options -MultiViews
        </Directory>

    Výraz `<<SECRET>>` nahradiť klúčom - tajomstvom, napríklad vygenerovaným pomocou príkazu `rake secret` spustenom v adresáry zdrojového kódu.

5. V priečinku nastavenom ako `DocumentRoot` vytvoriť symbolickú linku na priečinok so zdrojovým kód inštancie. Napríklad takto: `ln -s /home/user_aza/aza aza`.

6. Reštartovať webserver `/etc/init.d/apache2 restart`.


# Upgrade inštancie
Pokiaľ je WebTest nainštalovaný a chcete ho povýšiť, postupujte nasledovne:

1. Vypnúť webserver `/etc/init.d/apache2 stop`.
2. Updatnúť zdrojové súbory, napríklad zo vzdialeného úložiska pomocou príkazov spustených v adresári so zdrojovými kódmi:

        git fetch origin
        git reset --hard origin/osicky_develop

3. Do `/config/application.rb` treba doplniť: `config.relative_url_root = "/XXXX"`, kde `XXXX` značí sub-uri. 
4. Zmigrovať databázu na novú verziu príkazom `rake db:migrate RAILS_ENV=production`.
5. Spustiť: `rake assets:precompile`.
6. Zapnúť webserver `/etc/init.d/apache2 start`.

# Nastavenie databázy
Ak je správne nakonfigurované spojenie na databázu súborom `home/user_aza/aza/config/database.yml`, je možné manažovať databázu pre inštancie pomocou rails príkazov, tkz. `rake`.


Pre konkrétnu inštanciu sa spúšťajú príkazy v adresári zdrojového kódu inštancie. Rails pozná štandardne tri prostredia: development, production a test. Na koniec každého príkazu je možné doplniť, ktorého prostredia sa daný príkaz týka, pomocou `RAILS_ENV=production` sa napríklad príkaz viaže na produkčné prostredie. Ak nie je doplnené `RAILS_ENV`, tak príkaz sa viaže na vývojové prostredie.

## Zrušenie databázy
Príkaz `rake db:drop` zruší databázu.

## Vytvorenie databázy
Príkaz `rake db:create` vytvorí databázu. Obvykle sa používa dokopy s migračným príkazom.

## Migrácia databázy
Príkaz `rake db:migrate` zmigruje databázu. Migrácia databázy znamená, že budú do databázy nahrané všetky chýbajúce tabuľky a prepojenia, ktoré napríklad mohli byť pridané v novšej verzii. Tiež sa používa po vytvorení databázy na načítanie databázovej schémy ako inicializačný skript.

## Vytvorenie a inicializácia databázy pre inštanciu
Pre produkčné prostredie treba najprv vytvoriť a zmigrovať databázu.

        rake db:create RAILS_ENV=production
        rake db:migrate RAILS_ENV=production

Následne treba inicializovať niektoré tabuľky. 

### Tabuľka courses
Táto tabuľka obsahuje údaje o inštancii. Aktuálne do tabuľky courses je nutné zadať názov inštancie a časy vytvorenia a updatovania záznamu inštancie. Je možné túto tabuľku naplniť príkazom `rake tesa:data:aza_setup` pre testovacie účely, pričom sa naplní aj tabuľka weeks.

### Tabuľka weeks
Tabuľka weeks obsahuje týždne semestra. Je možné túto tabuľku naplniť príkazom `rake tesa:data:aza_setup` pre testovacie účely.

### Tabuľka users
Tabuľka users obsahuje používateľov systému. Odporúča sa administrátora predmetu pridať manuálne, pričom zvyšní používatelia budú pridaný pri ich prvom prihlásení AIS účtom. Tiež je možné pridať používateľov csv súborom pomocou príkazu 

    rake tesa:data:import_users[<<CESTA_K_SUBORU>>] 

Ukážka súboru je v časti úkažok konfiguračných súborov. 

### Tabuľka learning_objects a answers
Každý riadok tabuľky learning_objects obsahuje otázku, pričom ak sa jedná o otázku so zadanými odpoveďami, odpovede sa nachádzajú v tabuľke answers. Tabuľku je možné plniť pomocou administratívneho rozhrania v aplikácii alebo pomocou príkazu:

    rake tesa:data:import_tests[<<CESTA_K_SUBORU>>,<<CESTA_K_POUZITYM_OBRAZKOM>>]

### Tabuľka exercises
V tejto tabuľke sú zadané termíny testov. Termíny testov je možné vytvoriť v konfiguračnom rozhraní TESA alebo príkazom:

    rake tesa:data:import_exercises[<<CESTA_K_SUBORU>>]

# Ukážky konfiguračných súborov
V tejto časti sú ukážky súborov používaných na konfiguráciu a import.

## Databáza - database.yml
V súbore /home/aza_user/aza/config/database.yml sa upravujú prístupové údaje do databázy. Pre nakonfigurovanie prístupu kvôli produkčnému behu stačí upraviť časť týkajúcej sa produkcii:

    production:
     <<: *default
     database: aleftng_production_aza
     username: aza_db_username
     password: aza_db_password

Časť `default` môže byť nakonfigurovaná takto:

    default: &default
     adapter: postgresql
     encoding: unicode
     # For details on connection pooling, see rails configuration guide
     # http://guides.rubyonrails.org/configuring.html#database-pooling
     pool: 5


Viac informácii je v rails [dokumentácii](http://edgeguides.rubyonrails.org/configuring.html#configuring-a-database).

## Ldap - ldap.yml
V súbore `/home/aza_user/aza/config/ldap.yml` sa upravujú prístupové údaje na ldap spojenie. Na začiatku je vhodné si zadefinovať prístupové údaje na všetky ldap serveri, napríklad takto:

    stuba_ldap: &STUBA_LDAP
     host: ldap.stuba.sk
     port: 636
     attribute: uid
     base: ou=People,dc=stuba,dc=sk
     ssl: simple_tls

    stuba_ldap2: &STUBA_LDAP2
     host: ldap2.stuba.sk
     port: 636
     attribute: uid
     base: ou=People,dc=stuba,dc=sk
     ssl: simple_tls

Následne je možné použiť tieto údaje pre hociktoré prostredie, napríklad pre produkciu takto:

    production:
     -
     <<: *STUBA_LDAP
     -
     <<: *STUBA_LDAP2

Ak sa do časového limitu nepodarí spojiť s ldap serverom označeným ako `STUBA_LDAP`, tak sa TESA pokúsi spojiť s `STUBA_LDAP2`.

## Mail - production.yml
V súbore `/home/aza_user/aza/config/enviroments/production.yml` sa upravujú prístupové údaje na spojenie s mail serverom. Pre napríklad vývojárske prostredie treba upraviť súbor `/home/aza_user/aza/config/enviroments/development.yml` a podobne.

Posielanie mailov je riešené pomocou SMTP protokolu. Všetky nastavenia sa nachádzajú v časti `#Mail`. Príklad súboru:

    #Mail
    #Determines whether deliveries are actually carried out.
    config.action_mailer.perform_deliveries = true
    # Ignore bad email addresses and do not raise email delivery errors.
    # Set this to true and configure the email server for immediate delivery
    #to raise delivery errors.
    config.action_mailer.raise_delivery_errors = true
    # Defines a delivery method.
    config.action_mailer.delivery_method = :smtp
    #SMTP config
    config.action_mailer.smtp_settings = {
     address:              'mail.fiit.stuba.sk',
     port:                 25,
     domain:               'fiit.stuba.sk',
     enable_starttls_auto: false  }
    
    #Alows you to set default values for the mail method options
    config.action_mailer.default_options = {
     from: 'team17@fiit.stuba.sk', 
     to: 'team17@fiit.stuba.sk' }
     

Ak sa vyžaduje, do `config.action_mailer.smtp_settings` je možné zadať aj `user_name`, `password` a `authentication` (autentifikačná metóda, napríklad `login`). Podrobné vysvetlenie, aj ako použiť inú metódu ako SMTP je rails [dokumentácii](http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration).

## CSV súbor na pridanie používateľov
Príklad súboru:

    Login,Role,First name,Last name,Password,Type
    lucka,administrator,Maria,Lucka,'',LdapUser
    qbecka,teacher,Martin,Becka,'',LdapUser
    qlukotka,teacher,Robert,Lukotka,'',LdapUser
    qmazak,teacher,Jan,Mazak,qmazak,LocalUser

Vysvetlenie formátu:

1. Login - používateľské meno
2. Role - rola používateľa, sú podporované 3 roly: administrator, teacher, student
3. First name - prvé meno používateľa
4. Last name - priezvisko používateľa
5. Password - heslo používateľa, v databáze je uložená len jeho hash hodnota
6. Type - typ používateľského účtu, može byt LocalUser (vtedy sa neoveruje heslo pomocou LDAP) a LdapUser (správnosť hesla sa overuje pomocou Ldap)

## CSV súbor s definíciami otázok
Príklad súboru, konce riadkov sú označené pomocou "\n":

    Title,Question,Local Concepts,Global Concepts,Type,Answers,Difficulty,Image,
    Is special,Week\n
    Vtipna,Aký je na obrázku pokémon?,offtopic,prednaska,single-choice,pikachu;
    venusaur;<correct>charizard</correct>;digglet;persian;hitmonlee,lahke,
    /pokemon.png,TRUE,1\n
    Misova,Ako hodnotíte náš poster?,offtopic,prednaska,answer-validator,
    Poster je skvelý,lahke,,TRUE,1Triediace alg,Ktorý z nasledujúcich 
    tímov vyhrá?,sorts,cvicenie,multi-choice,<correct>Tesa</correct>;
    <correct>Tím 17</correct>;<correct>Osičky</correct>;iný,lahke,,TRUE,1\n
    Triediace alg,"Napíšte vaše pocity a nápady, ako vylepšiť náš projekt."
    ,sorts,cvicenie,open-question,,lahke,,TRUE,1\n
    Triediace alg,Kto vyhral v otázke položenej študentom Kto?,sorts,
    cvicenie;prednaska,single-choice,Superman;Spiderman;<correct>Batman
    </correct>;Ironman;Doktor,lahke,,TRUE,1\n

Vysvetlenie formátu:

1. Title - názov otázky
2. Question - samotný text otázky
3. Local Concepts - koncept viazaný na termín
4. Global concepts - koncept viazaný na týždne
5. Type - typ otázky, môže byť: single-choice, multi-choice, answer-validator, open-question
6. Answers - odpovede (oddelene pomocou ";") na otázku pri otázke typu single-choice a multi-choice; pomocou tagu <correct>odpoved</correct> je možné označiť správne odpovede
7. Difficulty - náročnosť otázky, môže byť: trivialne, lahke, stredne, tazke, impossible
8. Image - ku každej otázke je možné zadať jeden obrázok, v tejto položke treba zadať názov otázky a pri importe cestu k priečinku so všetkými obrázkami 
9. Is special - ak označené ako TRUE, tak túto otázku dostanú všetci študenti, inak FALSE
10. Week - id týždňa z tabuľky week

Rovice: Do otázok a odpovedí (Question a Answers) je možné formou tex výrazov zadávať rovnice. Rovnica sa vkladá medzi párový tag `/[` a `/]`.

## CSV súbor s termínmy testov
Príklad súboru:


    Exercise start,Exercise end,Code,Lecturer,Week,Local Concepts
    2016-04-04 14:00:00 +0200,2016-02-15 15:40:00 +0100,10008,3,8,prednaska
    2016-04-11 14:00:00 +0200,2016-02-15 15:40:00 +0100,10009,3,9,prednaska
    2016-04-18 14:00:00 +0200,2016-02-15 15:40:00 +0100,10010,3,10,prednaska
    2016-04-25 14:00:00 +0200,2016-02-15 15:40:00 +0100,10011,3,11,prednaska
    2016-05-02 14:00:00 +0200,2016-02-15 15:40:00 +0100,10012,3,12,prednaska
    2016-02-15 16:00:00 +0100,2016-02-15 17:40:00 +0100,10013,3,1,cvicenie
    2016-02-22 16:00:00 +0100,2016-02-15 17:40:00 +0100,10014,3,2,cvicenie
    2016-02-29 16:00:00 +0100,2016-02-15 17:40:00 +0100,10015,3,3,cvicenie
    2016-03-07 16:00:00 +0100,2016-02-15 17:40:00 +0100,10016,3,4,cvicenie

Vysvetlenie formátu:

1. Exercise start - štart termínu vo formáte YYYY-MM-DD HH-MM-SS zzz
2. Exercise end - koniec termínu vo formáte YYYY-MM-DD HH-MM-SS zzz
3. Code - kód pre študentov na vstup do termínu
4. Lecturer - id učiteľa v tabuľke users
5. Week - id týždňa v tabuľke weeks
6. Local Concepts - koncept viazaný na termíny

## Zmena počtu otázok, ktoré dostane študent na teste
V súbore `home/user_aza/aza/lib/tesa_simple_recommender.rb` označujú riadky:

    exercise_questions_count = 7
    student_questions_count = 4

počet otázok pre termín a počet otázok, ktoré dostane študent.

# Časté chyby

## Spojenie s db
Chyba `PG::ConnectionBad (FATAL: Peer authentication failed for user` v `/home/user_aza/aza/log/production.log`. Problém je s overovaním usera do databázy, buď je nesprávne heslo alebo nesprávna autentifikačná metóda nastavená. V druhom prípade v súbore `/etc/postgresql/9.3/mainpg_hba.conf` je databázový používateľ najčastejšie nastavený, že používa `local` nastavenie, teda `peer` autentifikačnú metódu, čo z dôvodu bezpečnosti nepodporuje `gem pg`, ktorý vyžaduje MD5 autentifikačnú metódu.

## Pád pri migrácii databázy (update databázy)
Ak nastane chyba 

    ERROR:  could not open extension control file "/usr/share/postgresql/9.3/extension/
    hstore.control": No such file or directory.
    
pri migrácii databázy (napríklad príkazom `rake db:migrate`), je nutné najprv doinštalovať knižnicu `apt-get install postgresql-contrib-9.3` a následne spustiť databázový príkaz `CREATE EXTENSION HSTORE` nad danou databázou.  

**Free Software, Hell Yeah!**
