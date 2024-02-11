## Laravel Todo App

Install the php dependencies
```
composer install
```

Create the env file
```
cp .env.example .env
```

Generate application key
```
php artisan key:generate
```

Install javascript dependencies
```
npm install
```

Install javascript dependencies
```
npm run build
```
*built assets are at <code>public/build</code> folder*

Run the tests
```
php artisan test
```

### Deploy docker containers
#### Debian distros
Run the bash script
```
bash ./build.sh
```

#### Windows docker (WSL)
Run the powershell script 
```
./build.ps1
```
