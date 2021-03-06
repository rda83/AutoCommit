
#Использовать tempfiles
#Использовать v8runner
#Использовать gitrunner	
#Использовать fs		
#Использовать logos		
#Использовать strings

// https://github.com/oscript-library/tempfiles
// https://github.com/oscript-library/v8runner
// https://github.com/oscript-library/gitrunner
// https://github.com/oscript-library/fs
// https://github.com/oscript-library/logos
// https://github.com/oscript-library/strings

// TODO Ошибка регулярки (особенность поиска ФИО разработчика)
// TODO Рефакторинг Инициализация
// TODO Рефакторинг Старт
// TODO Рефакторинг СообщенияСистемы
// TODO Описание механизма
// TODO Описание развертывания
// TODO Реализовать список возможных типов подключений к БД
// TODO Профили настроек
// TODO При возникновении исключений в объекте Конфигуратор, необходимо получать последнее сообщение
// TODO Перенести параметры лога в секцию Параметры
// TODO Реализовать файл ресурсов

Перем Контекст;

#Область Параметры_механизма

// Возвращает параметры механизма.
//
// Возвращаемое значение:
//	Структура - ключ - идентификатор параметра; значение - значение параметра
//
Функция ПараметрыМеханизма()

	Результат = Новый Структура();
	Результат.Вставить("ШаблонИмениКаталога", "^\d+$");
	Результат.Вставить("КорневойКаталогОбъектов", "C:\projects\autocommit\Objects\root\");
	Результат.Вставить("ФорматВыгрузки", РежимВыгрузкиКонфигурации.Плоский);
	Результат.Вставить("ПостфиксМодуляОбъекта", "*.ObjectModule.txt");
	Результат.Вставить("КодировкаМодулей", КодировкаТекста.UTF8);
	Результат.Вставить("ШаблонИнформацияОбОбъекте", "^\s(Возврат|Return)\s+(?'version'""\d+.\d+.\d+.\d+"")\s*;\s*\/\/[ ]*(?'prefix_comment'[А-Яа-я\w]+)[ ](?'dev_name'[А-Яа-я-]+[ ]+[А-Яа-я].[А-Яа-я].)[ ]+(?'date'\d\d.\d\d.\d\d\d\d)[ ](?'task_name'(\w|-)*\S)");

	ГруппыЗначений = Новый Соответствие();

	ГруппыЗначений.Вставить(3, "НомерВерсии");
	ГруппыЗначений.Вставить(4, "Подразделение");
	ГруппыЗначений.Вставить(5, "Разработчик");
	ГруппыЗначений.Вставить(6, "ДатаИзменений");
	ГруппыЗначений.Вставить(7, "Задача");

	Результат.Вставить("ГруппыЗначений", ГруппыЗначений);
	Результат.Вставить("КаталогРепозитория", "C:\temp\ExternalObjects_UPP_4");
	Результат.Вставить("ИмяЦелевойВетки", "master");
	Результат.Вставить("ЭлектроннаяПочтаКоммита", "autocommit@autocommit.local");
	Результат.Вставить("ГитСтатус_WorkingTreeClean", "nothing to commit, working tree clean");
	Результат.Вставить("ИмяПервогоФайлаВРепозитории", "init_commit");
	Результат.Вставить("РазработчикПоУмолчанию", "autocommit");

	ПараметрыПодключенияКФайловойБазе = Новый Структура;
	ПараметрыПодключенияКФайловойБазе.Вставить("Путь", "C:\Users\Denis\Documents\InfoBase1");
	ПараметрыПодключенияКФайловойБазе.Вставить("ИмяПользователя", "admin");
	ПараметрыПодключенияКФайловойБазе.Вставить("Пароль", "123");

	ПараметрыПодключенияКСервернойБазе = Новый Структура;
	ПараметрыПодключенияКСервернойБазе.Вставить("Сервер", "");
	ПараметрыПодключенияКСервернойБазе.Вставить("ИмяБазы", "");
	ПараметрыПодключенияКСервернойБазе.Вставить("ИмяПользователя", "");
	ПараметрыПодключенияКСервернойБазе.Вставить("Пароль", "");

	Результат.Вставить("ПараметрыПодключенияКФайловойБазе", ПараметрыПодключенияКФайловойБазе);
	Результат.Вставить("ПараметрыПодключенияКСервернойБазе", ПараметрыПодключенияКСервернойБазе);

	// Файловый
	// серверный
	// временная_база
	Результат.Вставить("ВариантПодключенияКБазе", "файловый");

	Результат.Вставить("Хранилище", Новый Структура("СтрокаСоединения, ПользовательХранилища, ПарольХранилища"
													, "C:\temp\stor"
													, "autocommit"
													, "1234567890"));

	Результат.Вставить("ОбновлятьКонфигурациюИзХранилища", Ложь);
	Результат.Вставить("ОчищатьКорневойКаталог", Ложь);

	Возврат Результат;

КонецФункции	

#КонецОбласти

#Область Инициализация_и_завершение_скрипта

// Инициализирует объект ГитРепозиторий
//
Процедура ИнициализацияГит()
	
	ГитРепозиторий 		= Новый ГитРепозиторий();
	ОшибкаВыполнения	= Ложь;

	Если НЕ ФС.КаталогСуществует(Контекст.Параметры.КаталогРепозитория) Тогда
		
		СоздатьКаталогРепозитория(ОшибкаВыполнения);
		
	КонецЕсли;
	ГитРепозиторий.УстановитьРабочийКаталог(Контекст.Параметры.КаталогРепозитория);		
	Контекст.Вставить("ГитРепозиторий", ГитРепозиторий);

	Если НЕ ОшибкаВыполнения 
		И НЕ ГитРепозиторий.ЭтоРепозиторий() Тогда

		ИнициализироватьНовыйРепозиторий(ОшибкаВыполнения);
		
	КонецЕсли;

	Если ОшибкаВыполнения Тогда

		ТекстСообщения = Контекст.Сообщение.ОшибкаИнициализации;
		Лог(ТекстСообщения, 4);
		ВызватьИсключение ТекстСообщения;
	КонецЕсли;		

КонецПроцедуры

// Инициализирует объект Конфигуратор
//
Процедура ИнициализацияКонфигуратор()

	Конфигуратор = Новый УправлениеКонфигуратором();
	
	Если Контекст.Параметры.ВариантПодключенияКБазе = "файловый" Тогда

		Путь 			= Контекст.Параметры.ПараметрыПодключенияКФайловойБазе.Путь;
		ИмяПользователя = Контекст.Параметры.ПараметрыПодключенияКФайловойБазе.ИмяПользователя;
		Пароль 			= Контекст.Параметры.ПараметрыПодключенияКФайловойБазе.Пароль;

		Конфигуратор.УстановитьКонтекст("/F"+Путь, ИмяПользователя, Пароль);

	ИначеЕсли Контекст.Параметры.ВариантПодключенияКБазе = "серверный" Тогда

		//Конфигуратор.УстановитьКонтекст("/IBConnectionString""Srvr=someserver:2041; Ref='database'""","Admin", "passw0rd");
	ИначеЕсли Контекст.Параметры.ВариантПодключенияКБазе = "временная_база" Тогда

		КаталогВременнойИБ = Контекст.ВременныйКаталог + "\ВременнаяБаза";
		Конфигуратор.КаталогСборки(КаталогВременнойИБ);
	Иначе

		ТекстСообщения = Контекст.Сообщение.НеизвестныйТипПодключенияКБазе + Контекст.Параметры.ВариантПодключенияКБазе;
		Лог(ТекстСообщения, 4);
		ВызватьИсключение ТекстСообщения;
	КонецЕсли;

	Контекст.Вставить("Конфигуратор", Конфигуратор);

КонецПроцедуры

// Действия перед работой основного механизма
//
Процедура Инициализация()

	Контекст = Новый Структура();
	Контекст.Вставить("Параметры", ПараметрыМеханизма());
	Контекст.Вставить("ВременныйКаталог", ВременныеФайлы.СоздатьКаталог());

	ИнициализацияКонфигуратор();

	РегулярноеВыражение = Новый РегулярноеВыражение(Контекст.Параметры.ШаблонИнформацияОбОбъекте);
	Контекст.Вставить("РегулярноеВыражение", РегулярноеВыражение);

	//Отладка
	//Информация
	//Предупреждение
	//Ошибка
	//КритичнаяОшибка
	
	Лог = Логирование.ПолучитьЛог("autocommit.app.messages");
	Лог.УстановитьРаскладку(ЭтотОбъект);
	Лог.УстановитьУровень(УровниЛога.Отладка);

	ФайлЖурнала = Новый ВыводЛогаВФайл;
	ВыводВКонсоль = Новый ВыводЛогаВКонсоль;
	ФайлЖурнала.ОткрытьФайл("C:\projects\autocommit\autocommit.app.messages.log");
	Лог.ДобавитьСпособВывода(ФайлЖурнала);
	Лог.ДобавитьСпособВывода(ВыводВКонсоль);

	Контекст.Вставить("Лог", Лог);

	Контекст.Вставить("Сообщение", СообщенияСистемы());

	ИнициализацияГит();

	Контекст.Вставить("СписокКаталоговДляУдаления", Новый Массив);

КонецПроцедуры

// Сообщения системы
//
// Возвращаемое значение:
//	Структура - ключ - идентификатор сообщения; значение - текст сообщения
//
Функция СообщенияСистемы()
	
	Результат = Новый Структура;
	
	Результат.Вставить("НекорректныйУровеньЛога", "Некорректный уровень лога.");
	Результат.Вставить("Запуск", "Начало работы системы.");
	Результат.Вставить("Завершение", "Завершение работы системы.");
	
	Результат.Вставить("СписокОбъектовЗапуск", "Запуск формирования списка объектов. Корневой каталог: ");
	Результат.Вставить("СписокОбъектовОбработкаЭлемента", "Список объектов. Обработка элемента: ");
	Результат.Вставить("СписокОбъектовНеКаталог", "Список объектов. Элемент не является каталогом.");
	Результат.Вставить("СписокОбъектовНеКорректноеИмя", "Список объектов. Элемент имеет не корректное имя.");
	Результат.Вставить("СписокОбъектовОпределенаМетрика", "Список объектов. Элементу определена метрика: ");
	Результат.Вставить("СписокОбъектовНачалоОбработкиСодержимогоПодкаталога", "Начало обработки содержимого подкаталога: ");
	Результат.Вставить("СписокОбъектовЗавершениеОбработкиСодержимогоПодкаталога", "Завершение обработки содержимого подкаталога. Обработано элементов: ");
	Результат.Вставить("СписокОбъектовНачалоОбработкиОбъекта", "Начало обработки объекта: ");
	Результат.Вставить("СписокОбъектовЗавершениеОбработкиОбъекта", "Завершение обработки объекта.");
	Результат.Вставить("СписокОбъектовЗавершениеОбъектНеОтчетОбработка", "Объект не является отчетом, или обработкой.");
	Результат.Вставить("СписокОбъектовЗавершение", "Завершение формирования списка объектов. Количество собранных объектов: ");

	Результат.Вставить("ОбработкаОбъектовНачало", "Обработка объектов. Начало.");
	Результат.Вставить("ОбработкаОбъектаНачало", "Обработка объекта. Начало. Объект: ");
	Результат.Вставить("ОбработкаОбъектаЗавершение", "Обработка объекта. Завершение.");
	Результат.Вставить("ОбработкаОбъектовЗавершение", "Обработка объектов. Завершение");

	Результат.Вставить("ОшибкаРазбораОбъекта", "Разбор объекта, ошибка: ");

	Результат.Вставить("ОписаниеОбъектаНеНайденМодульОбъекта", "Не найден модуль объекта.");
	Результат.Вставить("ОписаниеОбъектаНеНайденоОписаниеВерсии", "Не найдено описание версии объекта.");
	Результат.Вставить("ОписаниеОбъектаНайденМодульОбъекта", "Модуль объекта найден. Имя Файла: ");
	Результат.Вставить("ОписаниеОбъектаНайденоОписаниеВерсии", "Найдено описание версии объекта");
	Результат.Вставить("ЗначенияПолейОписания", "Значения полей описания: ");

	Результат.Вставить("ИсключениеПоместитьОбъектВКаталогХранилища", "Ошибка помещения объекта в каталог хранилища: ");
	Результат.Вставить("ПоместитьОбъектВКаталогХранилищаОпределенЦелевойКаталог", "Определен целевой каталог: ");
	Результат.Вставить("ПоместитьОбъектВКаталогХранилищаСозданЦелевойКаталог", "Целевой каталог создан.");
	Результат.Вставить("ПоместитьОбъектВКаталогХранилищаОчищенЦелевойКаталог", "Целевой каталог очищен.");
	Результат.Вставить("ПоместитьОбъектВКаталогХранилищаОбъектПомещенВЦелевойКаталог", "Объект помещен в целевой каталог.");

	Результат.Вставить("РепозиторийГитОшибкаПроверкиЦелевойВетки", "Ошибка во время определения статуса репозитория: ");
	Результат.Вставить("РепозиторийГитОшибкаПереходаВЦелевуюВетку", "Ошибка во время установки целевой ветки репозитория: ");
	Результат.Вставить("РепозиторийГитОшибкаПроверкиАктивностиЦелевойВетки", "Ошибка во время проверки целевой ветки репозитория: ");
	Результат.Вставить("РепозиторийГитУсловияПередФиксациейИзменений", "Ошибка. Не выполнены условия перед фиксацией изменений");
	Результат.Вставить("РепозиторийГитУсловияПослеФиксацииИзменений", "Ошибка. Не выполнены условия после фиксации изменений");
	Результат.Вставить("РепозиторийГитОшибкаВоВремяФиксацииИзменений", "Произошла ошибка во время фиксации изменений в репозитории. Описание: ");

	Результат.Вставить("РепозиторийГитУсловияПередФиксациейВыполнены", "Условия перед фиксацией выполнены.");
	Результат.Вставить("РепозиторийГитФиксацияВыполнена", "Фиксация выполнена. Текст сообщения коммита: ");
	Результат.Вставить("РепозиторийГитУсловияПослеФиксациейВыполнены", "Условия после фиксации выполнены.");

	Результат.Вставить("РепозиторийГитСозданиеКаталогаРепозитория", "Создан каталог репозитория: ");
	Результат.Вставить("РепозиторийГитСозданиеКаталогаРепозиторияОшибка", "Ошибка создания каталога репозитория: ");
	Результат.Вставить("РепозиторийГитИнициализацияРепозиторияОшибка", "Ошибка инициализации репозитория: ");
	Результат.Вставить("РепозиторийГитИнициализацияРепозитория", "Репозиторий успешно инициализирован.");
	Результат.Вставить("СообщениеПервогоКоммита", "initial commit");
	Результат.Вставить("ОшибкаИнициализации", "Ошибка инициализации.");

	Результат.Вставить("НеизвестныйТипПодключенияКБазе", "Неизвестный тип подключения к базе: ");

	Результат.Вставить("ОбновлениеКонфигурацииЗапрещено", "Обновление конфигурации из хранилища запрещено.");
	Результат.Вставить("ЗначениеСтрокиСоединенияСХранилищем", "Значение строки соединения с хранилищем: ");
	Результат.Вставить("УстановленныйВариантПодключенияКБазе", "Текущий вариант соединения с базой:");
	Результат.Вставить("ОбновлениеКонфигурацииЗапрещено", "Обновление конфигурации запрещено.");

	Результат.Вставить("ОшибкаУдаленияОбработанногоФайла", "Ошибка удаления обработанного файла. Описание: ");
	Результат.Вставить("КаталогНеПустУдалениеНеВозможно", "Каталог не пуст, удаление не возможно.");
	Результат.Вставить("УдаленКаталог", "Каталог удален: ");
	Результат.Вставить("ОшибкаУдаленияКаталога", "Ошибка удаления каталога. Описание: ");

	Возврат Результат;

КонецФункции

// Действия после работы основного механизма.
//
Процедура Завершение()

	ВременныеФайлы.Удалить();
	УдалитьПоСпискуКаталогов();
	Логирование.ЗакрытьЛог(Контекст.Лог);

КонецПроцедуры

#КонецОбласти

#Область Подготовка_списка_Объектов

// Вспомогательная для СписокОбъектов() функция, проверяет совпадение имени каталога регулярному выражению: Контекст.Параметры.ШаблонИмениКаталога.
//
// Возвращаемое значение:
// 	Булево - Истина - имя совпадает; Ложь - имя не совпадает.
//
Функция КорректноеИмяКаталога(ПроверяемаяСтрока)
	
	РегулярноеВыражение = Новый РегулярноеВыражение(Контекст.Параметры.ШаблонИмениКаталога);
	Возврат РегулярноеВыражение.Совпадает(ПроверяемаяСтрока);
	
КонецФункции

// Вспомогательная для СписокОбъектов() функция, возвращает пустую таблицу значений (контейнер) - для заполнения описаний объектов. 
//
// Возвращаемое значение: 
//  - Таблица значений - Список объектов каталога выгрузки.
//  	- Метрика			- числовое поле, по которому отсортирована коллекция. Задает очередь обработки объектов.
//		- ИмяОбъекта		- Полное имя файла отчета или обработки.
//		- ТипОбъекта 		- ".epf" - для обработок, ".erf" - для отчетов;
//		- КаталогИсточник	- каталог в котором находится необработанный файл.
//
Функция КонтейнерСпискаОбъектов()

	СписокОбъектов = Новый ТаблицаЗначений();
	СписокОбъектов.Колонки.добавить("Метрика");
	СписокОбъектов.Колонки.добавить("ИмяОбъекта");
	СписокОбъектов.Колонки.добавить("ТипОбъекта");
	СписокОбъектов.Колонки.добавить("КаталогИсточник");

	Возврат СписокОбъектов;

КонецФункции

// Возвращает описание объектов, находящихся в каталоге выгрузки: "Контекст.Параметры.КорневойКаталогОбъектов"
//  - в Контекст.Параметры.КорневойКаталогОбъектов - должны находится подкаталоги содержащие непосредственно отчеты и обработки.
//		- требования к имени подкаталога, содержащего отчет, обработку - имя должно включать только цифры.
//		- подкаталоги с именами которые не удовлетворяют требованиям будут пропущены. 
//		- файлы, которые находятся в Контекст.Параметры.КорневойКаталогОбъектов - будут пропущены.
//		- в подкаталогах могут находиться несколько отчетов, обработок.
//
//	- в последующем каждый объект списка будет разобран до исходного кода и помещен в репозиторий.
//		- обработка будет осуществляться в порядке следования метрик, начиная с наименьшей.
//
// Возвращаемое значение: см. КонтейнерСпискаОбъектов().  
//
Функция СписокОбъектов()

	Лог(Контекст.Сообщение.СписокОбъектовЗапуск + Контекст.Параметры.КорневойКаталогОбъектов);
	
	СписокОбъектов = КонтейнерСпискаОбъектов();
	СодержимоеКорневогоКаталога = НайтиФайлы(Контекст.Параметры.КорневойКаталогОбъектов, "*.*");

	Для каждого Элемент Из СодержимоеКорневогоКаталога Цикл

		Лог(Контекст.Сообщение.СписокОбъектовОбработкаЭлемента + Элемент.имя);

		Если НЕ Элемент.ЭтоКаталог() Тогда
			
			Лог(Контекст.Сообщение.СписокОбъектовНеКаталог, 2);
			Продолжить;
		КонецЕсли;
	
		Если НЕ КорректноеИмяКаталога(Элемент.имя) Тогда
			
			Лог(Контекст.Сообщение.СписокОбъектовНеКорректноеИмя, 2);
			Продолжить;
		КонецЕсли;
	
		Метрика = Число(Элемент.имя);
		Лог(Контекст.Сообщение.СписокОбъектовОпределенаМетрика + Метрика);

		Лог(Контекст.Сообщение.СписокОбъектовНачалоОбработкиСодержимогоПодкаталога + Элемент.ПолноеИмя);
		СодержимоеПодкаталога = НайтиФайлы(Элемент.ПолноеИмя, "*.*"); 
		Для каждого ДочернийЭлемент Из СодержимоеПодкаталога Цикл
			
			Лог(Контекст.Сообщение.СписокОбъектовНачалоОбработкиОбъекта + ДочернийЭлемент.ПолноеИмя);
			Если НЕ (ДочернийЭлемент.Расширение = ".epf"
						ИЛИ ДочернийЭлемент.Расширение = ".erf") Тогда
	
				Лог(Контекст.Сообщение.СписокОбъектовЗавершениеОбъектНеОтчетОбработка, 2);
				Продолжить;
			КонецЕсли;
		
			НоваяСтрока = СписокОбъектов.Добавить();
			НоваяСтрока.Метрика 		= Метрика;
			НоваяСтрока.ИмяОбъекта 		= ДочернийЭлемент.ПолноеИмя;
			НоваяСтрока.ТипОбъекта 		= ДочернийЭлемент.Расширение;
			НоваяСтрока.КаталогИсточник	= Элемент.ПолноеИмя;
			Лог(Контекст.Сообщение.СписокОбъектовЗавершениеОбработкиОбъекта);	
		КонецЦикла;
		Лог(Контекст.Сообщение.СписокОбъектовЗавершениеОбработкиСодержимогоПодкаталога + СодержимоеПодкаталога.Количество());
	
	КонецЦикла;
	СписокОбъектов.Сортировать("Метрика");

	Лог(Контекст.Сообщение.СписокОбъектовЗавершение + СписокОбъектов.Количество());
	Возврат СписокОбъектов;

КонецФункции

#КонецОбласти

#Область Конфигуратор

// Проверяет возможность, и необходимость обновления конфигурации из хранилища.
//
// Возвращаемое значение:
//	Булево - если Истина - обновление возможно;
//
//
Функция УсловияОбновленияКонфигурации()

	ПровестиПроцедуруОбновления = Истина;

	Если НЕ Контекст.Параметры.ОбновлятьКонфигурациюИзХранилища Тогда
	
		Лог(Контекст.Сообщение.ОбновлениеКонфигурацииЗапрещено);
		ПровестиПроцедуруОбновления = Ложь;
	КонецЕсли;

	Если Контекст.Параметры.Хранилище.СтрокаСоединения = "" Тогда
	
		Лог(Контекст.Сообщение.ЗначениеСтрокиСоединенияСХранилищем);
		ПровестиПроцедуруОбновления = Ложь;
	КонецЕсли;

	Если Контекст.Параметры.ВариантПодключенияКБазе = "временная_база" Тогда
	
		Лог(Контекст.Сообщение.УстановленныйВариантПодключенияКБазе);
		ПровестиПроцедуруОбновления = Ложь;
	КонецЕсли;

	Возврат ПровестиПроцедуруОбновления;

КонецФункции

// Обновляет конфигурацию из хранилища
// 	- при условиях: см. УсловияОбновленияКонфигурации().
//
Процедура ОбновитьКонфигурацию()
	
	Если НЕ УсловияОбновленияКонфигурации() Тогда

		Возврат;
	КонецЕсли;

	СтрокаСоединения 		= Контекст.Параметры.Хранилище.СтрокаСоединения;
	ПользовательХранилища 	= Контекст.Параметры.Хранилище.ПользовательХранилища;
	ПарольХранилища	 		= Контекст.Параметры.Хранилище.ПарольХранилища;

	Попытка
	
		Контекст.Конфигуратор.ЗагрузитьКонфигурациюИзХранилища(СтрокаСоединения, ПользовательХранилища, ПарольХранилища);
	Исключение

		ОписаниеОшибки = ОписаниеОшибки();
		СообщениеОбОшибке = Контекст.Сообщение.ОшибкаОбновленияКонфигурацииИзХранилища + ОписаниеОшибки;
		Лог(СообщениеОбОшибке, 4);
		ВызватьИсключение СообщениеОбОшибке; 
	КонецПопытки;
КонецПроцедуры

#КонецОбласти

#Область Работа_с_объектом

// Разбирает объект до исходного кода, и помещает результат во временный каталог.
//
// Параметры:
//	ОбъектДляОбработки - СтрокаТаблицыЗначений - см. КонтейнерСпискаОбъектов(). 
//
// Возвращаемое значение:
//	Строка, Неопределено - имя временного каталога содержащего результат работы функции, Неопределено - если работа завершилась ошибкой.	
//
Функция РазобратьОбъект(ОбъектДляОбработки)

	Результат = ВременныеФайлы.СоздатьКаталог();

	ПараметрыЭкспорта = Контекст.Конфигуратор.ПолучитьПараметрыЗапуска();
	ПараметрыЭкспорта.Добавить("/DumpExternalDataProcessorOrReportToFiles");
	ПараметрыЭкспорта.Добавить(СтрШаблон("""%1""", Результат));
	ПараметрыЭкспорта.Добавить(СтрШаблон("""%1""", ОбъектДляОбработки));
	ПараметрыЭкспорта.Добавить(СтрШаблон("-format %1", Контекст.Параметры.ФорматВыгрузки));

	Попытка
		
		Контекст.Конфигуратор.ВыполнитьКоманду(ПараметрыЭкспорта);
	Исключение
		
		Результат = Неопределено;
		ВыводКоманды = Контекст.Конфигуратор.ВыводКоманды();
		Лог(Контекст.Сообщение.ОшибкаРазбораОбъекта + ВыводКоманды, 3);
	КонецПопытки;
	
	Возврат Результат;

КонецФункции	

// Возвращает описание объекта для последующего коммита.
//	- ищет файл модуля объекта;
//	- по шаблону регулярного выражения (Контекст.Параметры.ШаблонИнформацияОбОбъекте) - находит информацию о версии объекта;
//	- состав информации можно посмотреть в структуре Контекст.Параметры.ГруппыЗначений;
//	- Контекст.Параметры.ГруппыЗначений - существование этой структуры обусловлено тем что движок регулярных выражений в "языке" oscript не позволяет обратиться к группе по имени, или индексу.
//
// Параметры:
//	КаталогКонтейнер - Строка - имя каталога который содержит результат разбора объекта.
//
// Возвращаемое значение:
//	Структура, Неопределено - состав структуры: ИмяФайла, КаталогКонтейнер + состав Контекст.Параметры.ГруппыЗначений.
//							 	Если модуль объекта не найден, возвращается Неопределено.
//
Функция ОписаниеОбъекта(КаталогКонтейнер)
	
	ГруппыЗначений = Контекст.Параметры.ГруппыЗначений;
	Результат = Неопределено;

	НайденныеЭлементы = НайтиФайлы(КаталогКонтейнер, Контекст.Параметры.ПостфиксМодуляОбъекта);
	Если НайденныеЭлементы.Количество() > 0 Тогда
		
		МодульОбъекта = НайденныеЭлементы[0];
		Лог(Контекст.Сообщение.ОписаниеОбъектаНайденМодульОбъекта + МодульОбъекта.ПолноеИмя);
		Результат = Новый Структура;
		
		ИмяФайла = Лев(МодульОбъекта.ИмяБезРасширения, Найти(МодульОбъекта.ИмяБезРасширения, ".") - 1);
		Результат.Вставить("ИмяФайла", ИмяФайла);
		Результат.Вставить("КаталогКонтейнер", КаталогКонтейнер);

		ЧтениеТекста = Новый ЧтениеТекста(МодульОбъекта.ПолноеИмя, Контекст.Параметры.КодировкаМодулей);
		МодульОбъектаИсходныйКод = ЧтениеТекста.Прочитать();
			
		РегулярноеВыражение = Контекст.РегулярноеВыражение;

		Совпадения = РегулярноеВыражение.НайтиСовпадения(МодульОбъектаИсходныйКод);

		Если НЕ Совпадения.Количество() = 0 Тогда
		
			Лог(Контекст.Сообщение.ОписаниеОбъектаНайденоОписаниеВерсии);
		Иначе

			Для каждого Элемент Из ГруппыЗначений Цикл
			
				Результат.Вставить(Элемент.Значение, "НеНайдено");
			КонецЦикла;

			Лог(Контекст.Сообщение.ОписаниеОбъектаНеНайденоОписаниеВерсии, 2);
		КонецЕсли;

		Для каждого Совпадение Из Совпадения Цикл
			
			ТекущийНомерГруппы = 0;
			Для каждого Группа Из Совпадение.Группы Цикл

				ИмяГруппы = ГруппыЗначений.Получить(ТекущийНомерГруппы);
				Если НЕ ИмяГруппы = Неопределено Тогда
				
					Лог(Контекст.Сообщение.ЗначенияПолейОписания + ИмяГруппы + " = " + Группа.Значение, 0);
					Результат.Вставить(ИмяГруппы, Группа.Значение); 
				КонецЕсли;

				ТекущийНомерГруппы = ТекущийНомерГруппы + 1;
			КонецЦикла;
			Прервать;
		КонецЦикла;
	Иначе
		
		Лог(Контекст.Сообщение.ОписаниеОбъектаНеНайденМодульОбъекта, 2);
	КонецЕсли;	
	ЧтениеТекста.Закрыть();

	Возврат Результат;

КонецФункции

// Копирует разобранный объект в каталог репозитория.
//	- имя каталога: Контекст.Параметры.КаталогРепозитория + имя файла модуля объекта без расширения
// 	- в случае отсутствия каталога, он будет создан
//	- если каталог существует, то его содержимое удаляется
// Параметры:
//	ОписаниеОбъекта - Структура - см. ОписаниеОбъекта().
// 
Процедура ПоместитьОбъектВКаталогХранилища(Знач ОписаниеОбъекта)
	
	РасположениеОбъекта = Контекст.Параметры.КаталогРепозитория + "\" + ОписаниеОбъекта.ИмяФайла;
	КаталогНаДиске = Новый Файл(РасположениеОбъекта);
	Лог(Контекст.Сообщение.ПоместитьОбъектВКаталогХранилищаОпределенЦелевойКаталог + РасположениеОбъекта);

	Попытка

		Если НЕ КаталогНаДиске.Существует() Тогда
			
			СоздатьКаталог(РасположениеОбъекта);
			Лог(Контекст.Сообщение.ПоместитьОбъектВКаталогХранилищаСозданЦелевойКаталог);
		Иначе

			УдалитьФайлы(РасположениеОбъекта, "*.*");
			Лог(Контекст.Сообщение.ПоместитьОбъектВКаталогХранилищаОчищенЦелевойКаталог);
		КонецЕсли;

		ФС.КопироватьСодержимоеКаталога(ОписаниеОбъекта.КаталогКонтейнер, РасположениеОбъекта);
		Лог(Контекст.Сообщение.ПоместитьОбъектВКаталогХранилищаОбъектПомещенВЦелевойКаталог);
		
	Исключение

		ОписаниеОшибки = ОписаниеОшибки();
		ВызватьИсключение Контекст.Сообщение.ИсключениеПоместитьОбъектВКаталогХранилища + ОписаниеОшибки;  
	КонецПопытки;
		
КонецПроцедуры

#КонецОбласти

#Область ГИТ

// Создает каталог репозитория, указанный в: Контекст.Параметры.КаталогРепозитория
//
// Параметры:
//	ОшибкаВыполнения - Булево - При возникновении ошибки в параметр будет записана Истина.
//
Процедура СоздатьКаталогРепозитория(ОшибкаВыполнения)

	Попытка
			
		СоздатьКаталог(Контекст.Параметры.КаталогРепозитория);
		Лог(Контекст.Сообщение.РепозиторийГитСозданиеКаталогаРепозитория + Контекст.Параметры.КаталогРепозитория);
	Исключение

		ОписаниеОшибки = ОписаниеОшибки();
		СообщениеКонтекста = Контекст.Сообщение.РепозиторийГитСозданиеКаталогаРепозиторияОшибка;
		ТекстСообщения =  СообщениеКонтекста + Контекст.Параметры.КаталогРепозитория + "Описание: " + ОписаниеОшибки;
		Лог(ТекстСообщения, 3);  
		ОшибкаВыполнения = Истина;
	КонецПопытки;
	
КонецПроцедуры

// Инициализирует новый репозиторий, создает и фиксирует первый коммит.
//
// Параметры:
//	ОшибкаВыполнения - Булево 			- При возникновении ошибки в параметр будет записана Истина.
//
Процедура ИнициализироватьНовыйРепозиторий(ОшибкаВыполнения)
	
	Попытка

		Контекст.ГитРепозиторий.Инициализировать();
		СоздатьФайлПервогоКоммита();
		ТекстСообщения 			= Контекст.Сообщение.СообщениеПервогоКоммита;
		ЭлектроннаяПочтаКоммита = ЭлектроннаяПочтаКоммита();
		Разработчик 			= Контекст.Параметры.РазработчикПоУмолчанию + " " + ЭлектроннаяПочтаКоммита;

		Контекст.ГитРепозиторий.ДобавитьФайлВИндекс(".");
		Контекст.ГитРепозиторий.Закоммитить(ТекстСообщения, Ложь,, Разработчик);

		Если НЕ ЦелеваяВеткаСуществует() Тогда
			
			Контекст.ГитРепозиторий.СоздатьВетку(Контекст.Параметры.ИмяЦелевойВетки);
		КонецЕсли;
		
		Лог(Контекст.Сообщение.РепозиторийГитИнициализацияРепозитория);			
	Исключение

		ОписаниеОшибки = ОписаниеОшибки();
		СообщениеКонтекста = Контекст.Сообщение.РепозиторийГитИнициализацияРепозиторияОшибка;
		ТекстСообщения =  СообщениеКонтекста + Контекст.Параметры.КаталогРепозитория + " Описание: " + ОписаниеОшибки;
		Лог(ТекстСообщения, 3);  
		ОшибкаВыполнения = Истина;
	КонецПопытки;

КонецПроцедуры

// Возвращает значение электронной почты для коммита.
//
// Возвращаемое значение:
//	Строка - Значение электронной почты коммита.
//
Функция ЭлектроннаяПочтаКоммита()
	
	Результат = "<" + Контекст.Параметры.ЭлектроннаяПочтаКоммита + ">"; 
	Возврат Результат;

КонецФункции

// Создает файл в каталоге репозитория, используется для первого коммита.
//
Процедура СоздатьФайлПервогоКоммита()
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.ДобавитьСтроку(ТекущаяДата());
	ИмяФайла = Контекст.Параметры.КаталогРепозитория + "\" + Контекст.Параметры.ИмяПервогоФайлаВРепозитории;
	ТекстовыйДокумент.Записать(ИмяФайла, КодировкаТекста.UTF8);

КонецПроцедуры

// Проверяет существование целевой ветки
//
// Возвращаемое значение:
//   Булево - если Истина - ветка существует.
//
Функция ЦелеваяВеткаСуществует()

	Результат = Ложь;

	СписокВеток = Контекст.ГитРепозиторий.ПолучитьСписокВеток();
	Отбор = Новый Структура("Имя", Контекст.Параметры.ИмяЦелевойВетки);
	НайденныеСтроки = СписокВеток.НайтиСтроки(Отбор);

	Если НайденныеСтроки.Количество() > 0 Тогда
	
		Результат = Истина;
	КонецЕсли;

	Возврат Результат;
КонецФункции

// Возвращает признак наличия незафиксированных изменений в репозитории.
//
// Возвращаемое значение:
//	Булево - если истина - то незафиксированных изменений в репозитории нет.
//
Функция ВсеИзмененияЗафиксированы()
	
	Результат = Ложь;

	Попытка
			
		Если СтрНайти(Контекст.ГитРепозиторий.Статус(), Контекст.Параметры.ГитСтатус_WorkingTreeClean) > 0 Тогда
	
			Результат = Истина;
		КонецЕсли;
	Исключение

		ОписаниеОшибки = ОписаниеОшибки();
		Лог(Контекст.Сообщение.РепозиторийГитОшибкаПроверкиЦелевойВетки + ОписаниеОшибки, 3);
	КонецПопытки;
	
	Возврат Результат;

КонецФункции

// Делает активной ветку указанную в Контекст.Параметры.ИмяЦелевойВетки
//
Процедура ПерейтиВЦелевуюВеткуРепозитория()
	
	Попытка
	
		Контекст.ГитРепозиторий.ПерейтиВВетку(Контекст.Параметры.ИмяЦелевойВетки);
	Исключение

		ОписаниеОшибки = ОписаниеОшибки();
		Лог(Контекст.Сообщение.РепозиторийГитОшибкаПереходаВЦелевуюВетку + ОписаниеОшибки, 3);
	КонецПопытки;
	
КонецПроцедуры

// В текущем репозитории активная ветка является целевой.
//
// Возвращаемое значение:
//   Булево   - если Истина - целевая ветка активна.
//
Функция УстановленаЦелеваяВеткаРепозитория()
	
	Результат = Ложь;

	Попытка
		
		Если Контекст.ГитРепозиторий.ПолучитьТекущуюВетку() = Контекст.Параметры.ИмяЦелевойВетки Тогда
		
			Результат = Истина;
		КонецЕсли;	

	Исключение

		ОписаниеОшибки = ОписаниеОшибки();
		Лог(Контекст.Сообщение.РепозиторийГитОшибкаПроверкиАктивностиЦелевойВетки + ОписаниеОшибки, 3);	
	КонецПопытки;

	Возврат Результат;

КонецФункции

// Делает активной ветку указанную в Контекст.Параметры.ИмяЦелевойВетки, проверяет успешность условий перед коммитом.
//
// Возвращаемое значение:
//   Булево - если Истина - все условия выполнены.
//
Функция УсловияПередФиксациейИзменений()

	Результат 	 = Ложь;
	
	ПерейтиВЦелевуюВеткуРепозитория();

	Если УстановленаЦелеваяВеткаРепозитория() Тогда	
		
		Результат = Истина;
	КонецЕсли;

	Возврат Результат;
	
КонецФункции

// Проверяет корректность фиксации изменений в репозитории.
//
// Возвращаемое значение:
//   Булево - если Истина - все условия выполнены.
//
Функция УсловияПослеФиксацииИзменений()

	Результат = Ложь;

	Если ВсеИзмененияЗафиксированы() Тогда
	
		Результат = Истина;

	КонецЕсли;

	Возврат Результат;

КонецФункции

// Фиксация изменений в репозитории.
//
// Параметры:
// 	ОписаниеОбъекта - Структура - см. см. ОписаниеОбъекта().
// 
Процедура ЗафиксироватьОбъект(Знач ОписаниеОбъекта)

	Если НЕ УсловияПередФиксациейИзменений() Тогда
	
		ВызватьИсключение Контекст.Сообщение.РепозиторийГитУсловияПередФиксациейИзменений;  
	КонецЕсли;		

	Лог(Контекст.Сообщение.РепозиторийГитУсловияПередФиксациейВыполнены);

	Попытка
	
		ТекстСообщения 			= ОписаниеОбъекта.Задача + " " + ОписаниеОбъекта.НомерВерсии + " " + ОписаниеОбъекта.Подразделение; 
		ЭлектроннаяПочтаКоммита = ЭлектроннаяПочтаКоммита();
		
		Контекст.ГитРепозиторий.ДобавитьФайлВИндекс(".");
		Разработчик 			= ОписаниеОбъекта.Разработчик + " " + ЭлектроннаяПочтаКоммита;	
		Контекст.ГитРепозиторий.Закоммитить(ТекстСообщения, Ложь,, Разработчик);

		Лог(Контекст.Сообщение.РепозиторийГитФиксацияВыполнена + ТекстСообщения);

	Исключение

		ОписаниеОшибки = ОписаниеОшибки();
		ВызватьИсключение Контекст.Сообщение.РепозиторийГитОшибкаВоВремяФиксацииИзменений + ОписаниеОшибки; 
	КонецПопытки;
		
	Если НЕ УсловияПослеФиксацииИзменений() Тогда
	
		ВызватьИсключение Контекст.Сообщение.РепозиторийГитУсловияПослеФиксацииИзменений; 
	КонецЕсли;				 

	Лог(Контекст.Сообщение.РепозиторийГитУсловияПослеФиксациейВыполнены);

КонецПроцедуры

#КонецОбласти

#Область Логирование

// Служебная функция подсистемы logos.
// 	- задает формат сообщения в логе.
//
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	
	НаименованиеУровня = СтроковыеФункции.ДополнитьСтроку(УровниЛога.НаименованиеУровня(Уровень), 15, " ", "Справа");
    Возврат СтрШаблон("[%1]: %2 - %3", ТекущаяДата(), НаименованиеУровня, Сообщение);

КонецФункции

// Записывает сообщение в лог файл.
//
// Параметры:
//	СообщениеДляВывода - Строка - текст сообщения.
//	Уровень	- Число - уровень логирования:
//		* 0 - отладка;
//		* 1 - информация (уровень по умолчанию);
//		* 2 - предупреждение;
//		* 3 - ошибка;
//		* 4 - критичная ошибка.
//
Процедура Лог(Знач СообщениеДляВывода, Знач Уровень = 1)

	Если Уровень = 0 Тогда

		Контекст.Лог.Отладка(СообщениеДляВывода);
	ИначеЕсли Уровень = 1 Тогда
		
		Контекст.Лог.Информация(СообщениеДляВывода);
	ИначеЕсли Уровень = 2 Тогда
		
		Контекст.Лог.Предупреждение(СообщениеДляВывода);
	ИначеЕсли Уровень = 3 Тогда

		Контекст.Лог.Ошибка(СообщениеДляВывода);
	ИначеЕсли Уровень = 4 Тогда

		Контекст.Лог.КритичнаяОшибка(СообщениеДляВывода);
	Иначе

		РезультатПодстановки = СтроковыеФункции.ВставитьПараметрыВСтроку(
			"[Сообщение] Переданный уровень: [Уровень]. Для: [СообщениеДляВывода]"
			, Новый Структура("Сообщение, Уровень, СообщениеДляВывода"
				, Контекст.Сообщение.НекорректныйУровеньЛога
				, Уровень
				, СообщениеДляВывода));

			Контекст.Лог.Ошибка(РезультатПодстановки);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область Работа_с_корневым_каталогом

// Заполняет список каталогов, которые необходимо удалить из корневой папки.
//
Процедура СформироватьСписокКаталоговДляУдаления(Знач СписокОбъектов)

	СписокКаталоговДляУдаления = СписокОбъектов.Скопировать(,"КаталогИсточник");
	СписокКаталоговДляУдаления.Свернуть("КаталогИсточник");
	Контекст.СписокКаталоговДляУдаления = СписокКаталоговДляУдаления.ВыгрузитьКолонку("КаталогИсточник");

КонецПроцедуры

// Удаляет каталоги из корневой папки.
//
Процедура УдалитьПоСпискуКаталогов()

	Если НЕ Контекст.Параметры.ОчищатьКорневойКаталог Тогда
		
		Возврат;
	КонецЕсли;

	Для каждого Элемент Из Контекст.СписокКаталоговДляУдаления Цикл
		
		Если НЕ ФС.КаталогПустой(Элемент) Тогда
			
			Лог(Контекст.Сообщение.КаталогНеПустУдалениеНеВозможно, 3);
			Продолжить;
		КонецЕсли;

		Попытка
		
			УдалитьФайлы(Элемент);
			Лог(Контекст.Сообщение.УдаленКаталог + Элемент);
		Исключение
			ОписаниеОшибки = ОписаниеОшибки();
			Лог(Контекст.Сообщение.ОшибкаУдаленияКаталога + ОписаниеОшибки, 3);
		КонецПопытки;

	КонецЦикла;

КонецПроцедуры

#КонецОбласти

Процедура Старт()

	ОбновитьКонфигурацию();
	СписокОбъектов = СписокОбъектов();

	Лог(Контекст.Сообщение.ОбработкаОбъектовНачало);
	Для каждого Элемент Из СписокОбъектов Цикл

		Лог(Контекст.Сообщение.ОбработкаОбъектаНачало + Элемент.ИмяОбъекта);
		
		КаталогКонтейнер = РазобратьОбъект(Элемент.ИмяОбъекта);

		Если НЕ КаталогКонтейнер = Неопределено Тогда
		
			ОписаниеОбъекта = ОписаниеОбъекта(КаталогКонтейнер);
			Если НЕ ОписаниеОбъекта = Неопределено Тогда 
				
				Попытка
				
					ПоместитьОбъектВКаталогХранилища(ОписаниеОбъекта);
				Исключение

					ОписаниеОшибки = ОписаниеОшибки();
					Лог(ОписаниеОшибки, 4);
					Прервать;
				КонецПопытки;
				
				Попытка
					
					ЗафиксироватьОбъект(ОписаниеОбъекта);
				Исключение

					ОписаниеОшибки = ОписаниеОшибки();
					Лог(ОписаниеОшибки, 4);
					Прервать;
				КонецПопытки;

				Если Контекст.Параметры.ОчищатьКорневойКаталог Тогда
					Попытка
						
						УдалитьФайлы(Элемент.ИмяОбъекта);
					Исключение
						ОписаниеОшибки = ОписаниеОшибки();
						Лог(Контекст.Сообщение.ОшибкаУдаленияОбработанногоФайла + ОписаниеОшибки, 3);
					КонецПопытки;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Лог(Контекст.Сообщение.ОбработкаОбъектаЗавершение);
	КонецЦикла;

	СформироватьСписокКаталоговДляУдаления(СписокОбъектов);
	Лог(Контекст.Сообщение.ОбработкаОбъектовЗавершение);	
КонецПроцедуры

Инициализация();
Лог(Контекст.Сообщение.Запуск);
Старт();
Завершение(); 
