# Ads SDK iOS

Это SDK - удобный инструмент монетизации приложений, совмещающий в себе рекламные объявления из аукциона стандарта OpenRTB (SSP Buzzoola) и другие рекламные сети (Яндекс и ВК).
С помощью этого SDK можно отразить в своем приложении несколько форматов рекламных объявлений, таких как: 
- Баннерная реклама - небольшое рекламное объявление с заданными размерами с возможностью автообновления;
- Нативная реклама - формат рекламы, внешний вид которой задается на стороне приложения;
- Полноэкранная реклама - формат рекламы, отражающейся на весь экран с видео или с картинкой;
- Реклама с вознаграждением - полноэкранный формат, за просмотр которого пользователь получает вознаграждение;
- Instream реклама - формат видеорекламы, в котором рекламный ролик встраивается в видеопоток и проигрывается по заданному сценарию: перед основным видео, в середине или в конце.

# Тех. информация

## Текущая версия

Версия: 3.1.1

## Требования для установки SDK

- iOS 13.0+

# Подключение SDK

Сейчас есть возможность подключить SDK только с помощью SPM.

## Swift Package Manager

Выберите File — Add Packages Dependencies. В поиск добавьте URL проекта, проверьте, что выбрана последняя версия 3.1.1 или задайте ее вручную, а после нажмите Add Package.

Ссылка на внешний репозиторий: 
```ruby
https://github.com/Buzzoola/buzzoola-ads-sdk
```

SDK имеет в себе три подмодуля.

1. Если вы хотите использовать только рекламу Buzzoola: подключите в свой проект модуль BuzzoolaAdsSDK и BuzzoolaAdsSDKAnalytics.

2. Если вы хотите использовать рекламу Buzzoola и ВК: подключите в свой проект модуль BuzzoolaAdsSDK, BuzzoolaAdsSDKMyTarget и BuzzoolaAdsSDKAnalytics.

Важно! Временно, для поддержки аналитики необходимо подключать еще дополнительный сторонний модуль по ссылке: 
```ruby
https://github.com/MobileTeleSystems/mts-analytics-swiftpm-ios-sdk
```

# Использование SDK

Принцип работы зависит от выбранного формата рекламы. 
- Баннерная реклама - необходимо создать вью нужного класса, разместить его в своей верстке, загрузить рекламу, и SDK наполнит это вью нужным содержимым;
- Нативная реклама - необходимо сверстать вью с множеством компонентов (текст, картинки, вью), связать компоненты, загрузить рекламу, и SDK наполнит это вью нужным содержимым;
- Полноэкранная реклама и реклама с вознаграждением - размещается на отдельном вью контроллере модально на весь экран, необходимо лишь передать нужному методу свой вью контроллер, поверх которого отразится данная реклама;
- Instream реклама - необходимо сверстать плеер, на котором будет показано рекламное видео, связать компоненты, разместить поверх вашего плеера и регулировать видимость, следуя необходимой логике.

## Инициализация SDK
Перед использованием обязательно выполнить инициализацию SDK. В этот момент осуществляется запрос доступа к рекламному идентификатору и вылазит системное уведомление пользователю вашего приложения. 
Предпочтительно размещать это в AppDelegate, чтобы точно гарантировать работу SDK. 
Без инициализации вызов методов SDK не имеет смысла.

```ruby
Ads().configure {
   // SDK was initialized.
}
```

## Вызов рекламы

Для показа рекламного объявления во всех форматах всегда изначально создается экземпляр класса AdsRequest - набор полей с вашим уникальным placementID и необходимыми параметрами для подбора удовлетворяющих запросу реклам.

```ruby
class AdsRequest
```

| Название поля          | Тип поля           | Обязательность         |
|:-----------------------|:-------------------|:-----------------------|
| placementID            | Int                | Да                     | // ваш уникальный placementID
| width                  | Int(?)             | Для формата баннер     | // максимально допустимая ширина баннера
| height                 | Int(?)             | Для формата баннер     | // максимально допустимая высота баннера
| latitude               | Double?            | Нет                    | // широта
| longitude              | Double?            | Нет                    | // долгота
| gender                 | Gender?            | Нет                    | // пол male/female, влияет только на рекламу Яндекс или ВК
| age                    | Int?               | Нет                    | // возраст, влияет только на рекламу Яндекс или ВК


### Баннерная реклама
Данный формат рекламы позволяет указывать максимально допустимые ширину и высоту рекламного объявления, которое вы желаете получить. 

#### Шаг 1: Создайте вью BannerAdView и разместите в своей верстке, где вам захочется

```ruby
var bannerView = BannerAdView()
```

#### Шаг 2: Создайте запрос для получения рекламы 

```ruby
let request = AdsRequest(placementID: placementID, width: width, height: height)
```
Если подобранный баннер будет меньшего размера, то он расположится в центре родительской вью.

#### Шаг 3: Вызовите метод loadAd(request: AdsRequest) для получения рекламы

```ruby
class ViewController: UIViewController {
    ...
    var bannerView = BannerAdView() # вью рекламного объявления  
    ...

    func viewDidLoad {
        let request = AdsRequest(placementID: placementID, width: width, height: height) # запрос для получение рекламы

        bannerView.loadAd(request: request) # вызов метода загрузки рекламы
    }
}
```

#### Шаг 4: Подпишитесь на делегат BannerAdEventProtocol, чтобы отслеживать события рекламы

```ruby
extension ViewController: BannerAdEventProtocol {

    # Метод для обработки результата загрузки

    func onAdLoaded() {}

    # Метод для обработки impression - события, когда реклама засчитана
    # Параметры:
    # — data: String? — дополнительная информация, присутствует для реклам Яндекса

    func onImpression(_ data: String?) {}

    # Метод для обработки кликов по рекламному объявлению 

    func onAdClicked() {}

    # Метод для обработки выходов из приложения

    func onLeftApplication() {}

    # Метод для обработки возврата в приложение

    func onReturnedToApplication() {}

    # Метод для обработки ошибки загрузки
    # Параметры:
    # — adError: AdError - ошибка получения рекламы

    func onAdFailed(adError: AdError) {}
}
```

#### Шаг 5: Вызовите метод destroy() для загрузки следующего баннера
Для повторной загрузки рекламы предварительно необходимо вызвать метод destroy() перед очередным loadAd. Метод очистит вью, верстку, обеспечит отсутствие утечек памяти и конфликтов констрейнтов для последующего отображения. 

#### Автообновление баннеров
Есть возможность настроить автообновление баннеров, в этом случае нет необходимости в ручную всякий раз вызывать метод loadAd и destroy для следуюшей загрузки рекламного объявления. Баннеры будут меняться друг за другом автоматически по заданному таймеру. 
Для поддержки автообновления, вызовите метод setRefreshAd(_ time: Int) у BannerAdView. В параметрах можно указать время обновления баннера в диапазоне от 10 секунд до 1 минуты. По умолчанию время обновления составляет 30 секунд. 
Важно: установливать автообновление необходимо до функции loadAd.

```ruby
class ViewController: UIViewController {
    ...
    var bannerView = BannerAdView() # вью рекламного объявления  
    ...

    func viewDidLoad {
        let request = AdsRequest(placementID: placementID, width: width, height: height) # запрос для получение рекламы

        bannerView.setRefreshAd(10) # автообновение баннера каждые 10 секунд
        bannerView.loadAd(request: request) # вызов метода загрузки рекламы
    }
}
```
### Нативная реклама
Этот формат рекламы позволяет создать рекламное объявление с кастомной версткой. 

#### Шаг 0: Создайте кастомную вьюху с необходимыми элементами
Данную вью необходимо унаследовать от класса NativeAdView.

```ruby
class NativeCustomAdView: NativeAdView {

    private var title: UILabel?

    private var domain: UILabel?

    ...
}
```

Для отображения рекламы должны быть использованы следующие элементы:

| Элемент       | Описание               | Тип элемента           | Обязательность     |
|:--------------|:-----------------------|:-----------------------|:-------------------|
| adTitle       | Заголовок              | UILabel                | Да                 |
| adDomain      | Домен                  | UILabel                | Да                 |
| adAge         | Возрастная метка       | UILabel                | Да                 |
| adBadge       | Рекламная метка        | UILabel                | Да                 |
| adWarning     | Предупреждение         | UILabel                | Да, для медиаций   |
| adInfo        | Значок меню            | UIButton               | Да                 |
| adActionBtn   | Кнопка действия        | UIButton               | Да                 |
| adMedia       | Медиа (картинка/видео) | NativeMediaView        | Да                 |
| adIcon        | Иконка                 | UIImageView            | Да, для типа APP   | 
| adPrice       | Цена                   | UILabel                | Да, для типа APP   |
| adDescription | Основной текст         | UILabel                | Нет                |
| adFavicon     | Значок веб-сайта       | UIImageView            | Нет                |
| adReviews     | Количество оценок      | UILabel                | Нет                |
| adRating      | Рейтинг                | View implements Rating | Нет                |

#### Шаг 1: Cвяжите элементы с вашей версткой

```ruby
func bindAssets() {
    adTitle = title
    adDomain = domain
    adWarning = warning
    adBadge = sponsored
    adInfo = feedback
    adActionBtn = callToAction
    adMedia = media
    adPrice = price
    adReviews = reviewCount
    adRating = ratingView
    adDescription = body
    adIcon = iconImage
    adAge = age
}
```

#### Шаг 2: Создайте загрузчик объекта рекламы, используя NativeAdLoader
Создайте экземпляр класса NativeAdLoader.

```ruby
class ViewController: UIViewController {

    private lazy var adLoader: NativeAdLoader = {
        let adLoader = NativeAdLoader()
        adLoader.delegate = self
        return adLoader
    }()
}
```

#### Шаг 3: Подпишите NativeAdLoader на NativeAdLoaderProtocol, для получения уведомлений о загрузке и ошибке
Загрузка осуществляется асинхронно, при получении рекламы вызываются соответствущие методы делегата.

```ruby
extension ViewController: NativeAdLoaderProtocol {

    # Метод для обработки результата загрузки
    # Параметры:
    # — ads: [NativeAd] - полученные рекламы

    func onAdsLoaded(ads: [NativeAd]) {}

    # Метод для обработки ошибки загрузки
    # Параметры:
    # — adError: AdError - ошибка получения рекламы

    func onAdsFailed(adError: AdError) {}
}
```

#### Шаг 4: Создайте запрос для получения реклам

```ruby
let request = AdsRequest(placementID: placementID)
```

#### Шаг 5: Вызовите метод loadAd(request: AdsRequest) для получения рекламы

```ruby
class ViewController: UIViewController {

    # Лоадер для загрузки реклам

    private lazy var adLoader: NativeAdLoader = { 
        let adLoader = NativeAdLoader()
        adLoader.delegate = self  # подписка на делегат NativeAdLoaderDelegate
        return adLoader
    }()

    func viewDidLoad {
        let request = AdsRequest(placementID: placementID,) # запрос для получение рекламы

        adLoader.loadAd(request: request) # вызов метода загрузки реклам
    }
}
```

#### Шаг 6: Выберите NativeAd для отображения и подпишите на делегат NativeAdDelegate для отслеживания событий по рекламному объявлению

```ruby
extension ViewController: NativeAdDelegate {

    # Метод для обработки результата отображения рекламного объявления
    # Параметры:
    # - ad: NativeAd - текущая реклама

    func onAdLoaded(_ ad: NativeAd) {}

    # Метод для обработки ошибки отображения рекламного объявления
    # Параметры:
    # - ad: NativeAd - текущая реклама
    # - adError: AdError - ошибка отображения рекламы

	func onAdFailed(_ ad: NativeAd, adError: AdError) {}

    # Метод для обработки закрытия рекламного объявления
    # Параметры:
    # - ad: NativeAd - текущая реклама

	func onCloseAd(_ ad: NativeAd) {}

    # Метод для обработки кликов по рекламному объявлению 
    # Параметры:
    # - ad: NativeAd - текущая реклама

	func onAdClicked(_ ad: NativeAd) {}

    # Метод для обработки выходов из приложения
    # Параметры:
    # - ad: NativeAd - текущая реклама

	func onLeftApplication(_ ad: NativeAd) {}

    # Метод для обработки возврата в приложение
    # Параметры:
    # - ad: NativeAd - текущая реклама

	func onReturnedToApplication(_ ad: NativeAd) {}

    # Метод для обработки impression - события, когда реклама засчитана
    # Параметры:
    # - ad: NativeAd - текущая реклама
    # — data: String? — дополнительная информация, присутствует для реклам Яндекса

	func onImpression(_ ad: NativeAd, _ data: String?) {}
}
```

#### Шаг 7: Подпишите выбранный NativeAd на делегат ImageLoadingDelegate для отслеживания загрузки картинок

```ruby
extension ViewController: ImageLoadingDelegate {

    # Метод для обработки загрузки картинки
    # Параметры:
    # - color: UIColor? - приоритетный цвет полученной картинки

    func onImageLoaded(color: UIColor?) {}

    # Метод для обработки ошибки загрузки картинки

    func onImageLoadFailed() {}
}
```

#### Шаг 8: Свяжите выбранный NativeAd с вашей кастомной вью методом bindAd для наполнения вашей вью рекламным контентом

```ruby
extension ViewController: NativeAdLoaderProtocol {

    func onAdsLoaded(ads: [NativeAd]) {
        let ad = ads.first # выбор первой рекламы для отображения

        ad?.delegate = self # подписка на делегат NativeAdDelegate
        ad?.imageDelegate = self # подписка на делегат ImageLoadingDelegate

        ad?.bindAd(yourCustomView) # связка рекламного объявления с кастомной вью для отображения
    }
}
```

#### Шаг 9: Вызовите метод destroy() для показанного NativeAd для отображения следующей рекламы
Для отображения следующей рекламы предварительно необходимо вызвать метод destroy() перед очередным bindAd. Метод очистит вью, верстку, обеспечит отсутствие утечек памяти и конфликтов констрейнтов для последующего отображения. 

#### Ресурсы рекламы

У рекламы NativeAd можно получить доступ к полю type: NativeAdType - тип полученной рекламы (app или content, значение app принимает только в случае с особой рекламой Яндекса), а так же к полю adAssets: NativeAdAssets - ресурсы рекламы от заголовка, до картинки. 

### InStream реклама
В зону отвественности пользователя для данного формата входит кастомизация плеера и логика скрытия и появления данной рекламы поверх своего видео. 

#### Шаг 0: Создайте свой кастомный плеер с необходимыми элементами
Данную вью необходимо унаследовать от класса InstreamPlayerView. 

Для отображения рекламы на этом вью должны присутствовать следующие элементы:

| Id элемента   | Описание               | Тип элемента           |
|:--------------|:-----------------------|:-----------------------|
| adBadge       | Рекламная метка        | UILabel                | 
| adInfo        | Значок меню            | UIButton               |
| adActionBtn   | Кнопка действия        | UIButton               |
| adMedia       | Медиа (видео)          | NativeMediaView        |

Вы можете кастомизировать InstreamPlayerView с помощью следующих методов:

```ruby

# Метод для задания фона видео
# Параметры:
# — color: UIColor - цвет для фона видео

func setBackground(_ color: UIColor)

# Метод для задания видимости линии прогресса
# Параметры:
# — show: Bool - по дефолту true - видима

func showProgressBar(_ show: Bool)

# Метод для задания цвет линии прогресса
# Параметры:
# — color: UIColor - цвет линии прогресса

func setProgressBarColor(_ color: UIColor)

# Метод для задания цвета и фона лоадера
# Параметры:
# — color: UIColor - цвет лоадера
# — background: UIColor? - цвет подложки лоадера, по дефолту hex: 333333 с непрозрачностью 0,64

func setLoader(color: UIColor, background: UIColor?)
```

#### Шаг 1: Cвяжите элементы с вашей версткой

```ruby
func bindAssets() {
    adBadge = badgeLabel
    adInfo = infoButton
    adActionBtn = actionButton
    adMedia = media
}
```

#### Шаг 2: Создайте загрузчик объекта рекламы, используя InstreamAdLoader
Создайте экземпляр класса InstreamAdLoader.

```ruby
class ViewController: UIViewController {

    private lazy var adLoader: InstreamAdLoader = {
        let adLoader = InstreamAdLoader()
        adLoader.delegate = self
        return adLoader
    }()
}
```

#### Шаг 3: Подпишите InstreamAdLoader на InstreamAdLoaderProtocol, для получения уведомлений о загрузке и ошибке
Загрузка осуществляется асинхронно, при получении рекламы вызываются соответствущие методы делегата.

```ruby
extension ViewController: InstreamAdLoaderProtocol {

    # Метод для обработки результата загрузки
    # Параметры:
    # — ad: InstreamAd - полученная видео-реклама

    func onAdLoaded(ad: InstreamAd) {}

    # Метод для обработки ошибки загрузки
    # Параметры:
    # — adError: AdError - ошибка получения рекламы

    func onAdFailed(adError: AdError) {}
}
```

#### Шаг 4: Создайте запрос для получения реклам

```ruby
let request = AdsRequest(placementID: placementID)
```

#### Шаг 5: Вызовите метод loadAd(request: AdsRequest) для получения рекламы

```ruby
class ViewController: UIViewController {

    # Лоадер для загрузки реклам

    private lazy var adLoader: InstreamAdLoader = { 
        let adLoader = InstreamAdLoader()
        adLoader.delegate = self  # подписка на делегат InstreamAdLoaderDelegate
        return adLoader
    }()

    func viewDidLoad {
        let request = AdsRequest(placementID: placementID,) # запрос для получение рекламы

        adLoader.loadAd(request: request) # вызов метода загрузки реклам
    }
}
```

#### Шаг 6: Подпишите полученный InstreamAd на делегат InstreamAdPlaybackDelegate для отслеживания событий по рекламному объявлению

```ruby
extension ViewController: InstreamAdPlaybackDelegate {

    # Метод для обработки результата завершения воспроизведения рекламных видео
    # Здесь можно запустить заново основное видео

    func onComplete() {}

    # Метод для обработки ошибки отображения рекламного объявления
    # Параметры:
    # - adError: AdError - ошибка отображения/воспроизведения рекламы

    func onFailed(adError: AdError) {}

    # Метод для обработки начала воспроизведение всех рекламных видео
    # InstreamPlayerView должен стать видимым, если был скрыт

    func onStarted() {}

    # Метод для обработки начала воспроизведения рекламного видео
    # Параметры:
    # - video: VideoAd - воспроизводимое видео 

    func onVideoAdStarted(video: VideoAd) {}

    # Метод срабатывает каждую секунду, уведомляя сколько осталось времени до конца воспроизведения видео. 
    # Здесь можно настроить таймер и кнопку "Пропустить"
    # Параметры:
    # - video: VideoAd - воспроизводимое видео 
    # - timeLeft: Float - прошло времени

    func onVideoAdTimeLeftChange(video: VideoAd, timeLeft: Float) {}

    # Метод для обработки завершения воспроизведения рекламного видео
    # Параметры:
    # - video: VideoAd - воспроизводимое видео 

    func onVideoAdCompleted(video: VideoAd) {}

    # Метод для обработки паузы воспроизведения рекламного видео
    # Параметры:
    # - video: VideoAd - воспроизводимое видео 

    func onVideoAdPaused(video: VideoAd) {}

    # Метод для обработки возобновления воспроизведения рекламного видео после паузы
    # Параметры:
    # - video: VideoAd - воспроизводимое видео 

    func onVideoAdResumed(video: VideoAd) {}

    # Метод для обработки ошибки воспроизведения рекламного видео
    # Параметры:
    # - video: VideoAd - воспроизводимое видео 
    # - error: String - причина ошибки

    func onVideoAdError(video: VideoAd, error: String) {}

    # Метод для обработки impression - события, когда реклама засчитана
    # Параметры:
    # - video: VideoAd - воспроизводимое видео 

    func onVideoAdImpression(video: VideoAd) {}

    # Метод для обработки кликов по рекламному видео
    # Параметры:
    # - video: VideoAd - воспроизводимое видео 

    func onVideoAdClicked(video: VideoAd) {}
}
```
#### Шаг 6: Свяжите InstreamAd с вашим кастомным плеером методом attachPlayerView для наполнения рекламным контентом и начните воспроизведение реклам  

```ruby
extension ViewController: NativeAdLoaderProtocol {

    func onAdLoaded(ad: InstreamAd) {
        ad.playbackDelegate = self # подписка на делегат InstreamAdPlaybackDelegate

        ad.attachPlayerView(yourCustomPlayer) # связка рекламного объявления с кастомным плеером для отображения

        ad.start() # старт воспроизведения видео-реклам
    }
}
```

#### Объект InstreamAd

В одном объекте InstreamAd в рамках одного рекламного блока может прийти несколько видео. Они будут автоматически запущены друг за другом. Их количество можно увидеть в поле InstreamAd.videoCount.
Если во время воспроизведения видео произойдет ошибка, следующее видео будет запущено автоматически или выполнено завершение показа рекламы, если ошибочное видео было последним.

Описание дополнительных методов:
```ruby
# Метод, позволяющий пропустить текущее рекламное видео
func skip()

# Метод, позволяющий остановить показ всего рекламного блока
func stop()

# Метод, позволяющий обработать клик по рекламе (при необходимости его дополнительного вызова)
func handleClick()

# Метод, позволяющий изменить звук видео. Значения от 0.0 до 1.0. 
# По дефолту видео запускается с выключенным звуком

func setVolume(volume: Float)
```

#### Объект VideoAd

Объект VideoAd содержит в себе поля duration и skipOffset, длина видео и время, через которое будет разрешен пропуск видео (в секундах). Обратите внимание, что skipOffset может быть равен duration, в таком случае пропуск по сути невозможен.

### Interstitial реклама

#### Шаг 1: Создайте загрузчик объекта рекламы, используя InterstitialAdLoader
Создайте экземпляр класса InterstitialAdLoader.

```ruby
private lazy var adLoader: InterstitialAdLoader = {
    let adLoader = InterstitialAdLoader()
    adLoader.delegate = self
    return adLoader
}()
```

#### Шаг 2: Подпишите InterstitialAdLoader на InterstitialAdLoaderProtocol, для получения уведомлений о загрузке и ошибке
Загрузка осуществляется асинхронно, при получении рекламы вызываются соответствущие методы делегата.

```ruby
extension ViewController: InterstitialAdLoaderProtocol {

    # Метод для обработки результата загрузки
    # Параметры:
    # — ad: InterstitialAd - полученная реклама

    func onAdLoaded(ad: InterstitialAd) {}

    # Метод для обработки ошибки загрузки
    # Параметры:
    # — adError: AdError - ошибка получения рекламы

    func onAdFailedToLoad(adError: AdError) {}
}
```

#### Шаг 3: Создайте запрос для получения реклам

```ruby
let request = AdsRequest(placementID: placementID)
```

#### Шаг 4: Вызовите метод loadAd(request: AdsRequest) для получения рекламы

```ruby
class ViewController: UIViewController {

    # Лоадер для загрузки реклам

    private lazy var adLoader: InterstitialAdLoader = { 
        let adLoader = InterstitialAdLoader()
        adLoader.delegate = self  # подписка на делегат InterstitialAdLoaderDelegate
        return adLoader
    }()

    func viewDidLoad {
        let request = AdsRequest(placementID: placementID,) # запрос для получение рекламы

        adLoader.loadAd(request: request) # вызов метода загрузки реклам
    }
}
```

#### Шаг 5: Подпишите полученный InterstitialAd на делегат InterstitialAdDelegate для отслеживания событий по рекламному объявлению

```ruby
extension ViewController: InterstitialAdDelegate {

    # Метод для обработки результата отображения рекламного объявления

    func onAdShown() {}

    # Метод для обработки ошибки отображения рекламного объявления
    # Параметры:
    # - adError: AdError - ошибка отображения рекламы

    func onAdFailed(adError: AdError) {}

    # Метод для обработки кликов по рекламному объявлению

    func onAdClicked() {}

    # Метод для обработки закрытия рекламного объявления

    func onAdDismissed() {}

    # Метод для обработки impression - события, когда реклама засчитана
    # Параметры:
    # — data: String? — дополнительная информация, присутствует для реклам Яндекса

    func onImpression(_ data: String?) {}
}
```

#### Шаг 6: Отобразите рекламное объявление
Необходимо передать ваш активный вью контроллер в качестве параметра методу show.

```ruby

extension ViewController: InterstitialAdLoaderProtocol {

    func onAdLoaded(ad: InterstitialAd) {
        ...
        ad.delegate = self # подписка на делегат InterstitialAdDelegate

        ad.show(from: self) # отображение рекламного объявления
        ...
    }
}
```

### Rewarded реклама

#### Шаг 1: Создайте загрузчик объекта рекламы, используя RewardedAdLoader
Создайте экземпляр класса RewardedAdLoader.
```ruby
private lazy var adLoader: RewardedAdLoader = {
    let adLoader = RewardedAdLoader()
    adLoader.delegate = self
    return adLoader
}()
```

#### Шаг 2: Подпишите RewardedAdLoader на RewardedAdLoaderProtocol, для получения уведомлений о загрузке и ошибке
Загрузка осуществляется асинхронно, при получении рекламы вызываются соответствущие методы делегата.

```ruby
extension ViewController: RewardedAdLoaderProtocol {

    # Метод для обработки результата загрузки
    # Параметры:
    # — ad: RewardedAd - полученная реклама

    func onAdLoaded(ad: RewardedAd) {}

    # Метод для обработки ошибки загрузки
    # Параметры:
    # — adError: AdError - ошибка получения рекламы

    func onAdFailedToLoad(adError: AdError) {}
}
```

#### Шаг 3: Создайте запрос для получения реклам

```ruby
let request = AdsRequest(placementID: placementID)
```

#### Шаг 4: Вызовите метод loadAd(request: AdsRequest) для получения рекламы

```ruby
class ViewController: UIViewController {

    # Лоадер для загрузки реклам

    private lazy var adLoader: RewardedAdLoader = { 
        let adLoader = RewardedAdLoader()
        adLoader.delegate = self  # подписка на делегат RewardedAdLoaderDelegate
        return adLoader
    }()

    func viewDidLoad {
        let request = AdsRequest(placementID: placementID,) # запрос для получение рекламы

        adLoader.loadAd(request: request) # вызов метода загрузки реклам
    }
}
```

#### Шаг 5: Подпишите полученный RewardedAd на делегат RewardedAdDelegate для отслеживания событий по рекламному объявлению

```ruby
extension RewardedView: RewardedAdDelegate {

    # Метод для обработки результата отображения рекламного объявления

    func onAdShown() {}

    # Метод для обработки ошибки отображения рекламного объявления
    # Параметры:
    # - adError: AdError - ошибка отображения рекламы

    func onAdFailed(adError: AdError) {}

    # Метод для обработки кликов по рекламному объявлению

    func onAdClicked() {}

    # Метод для обработки закрытия рекламного объявления

    func onAdDismissed() {}

    # Метод для обработки impression - события, когда реклама засчитана
    # Параметры:
    # — data: String? — дополнительная информация, присутствует для реклам Яндекса

    func onImpression(_ data: String?) {}

    # Метод для обработки получения вознаграждения. 
    # Срабатывает по истечению 15 секунд для реклам с картинкой и после просмотра видео для видео-реклам
    # Параметры:
    # — reward: Reward - структура с полями type: String (тип) и amount: Int? (стоимость)

    func onReward(reward: Reward) {}
}
```

#### Шаг 6: Отобразите рекламное объявление
Необходимо передать ваш активный вью контроллер в качестве параметра методу show.

```ruby

extension ViewController: RewardedAdLoaderProtocol {

    func onAdLoaded(ad: RewardedAd) {
        ...
        ad.delegate = self

        ad.show(from: self)
        ...
    }
}
```
