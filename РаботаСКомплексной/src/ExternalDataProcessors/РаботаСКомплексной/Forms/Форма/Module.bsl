
&НаКлиенте
Процедура НазваниеФайлаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	#Если ВебКлиент Тогда
		Если Не ПодключитьРасширениеРаботыСФайлами() Тогда
			
			НачатьУстановкуРасширенияРаботыСФайлами(Неопределено);
			ПодключитьРасширениеРаботыСФайлами();
		КонецЕсли;
	#КонецЕсли
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьВыборФайлаRk", ЭтаФорма);
    ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
    ДиалогОткрытияФайла.Заголовок = "Выбор файла";
    ДиалогОткрытияФайла.Фильтр = "xls*-файлы(*.xls*)|*.xls*|";
    ДиалогОткрытияФайла.ИндексФильтра = 0;
    ДиалогОткрытияФайла.ПредварительныйПросмотр = Ложь;
    ДиалогОткрытияФайла.ПроверятьСуществованиеФайла = Истина;
    ДиалогОткрытияФайла.МножественныйВыбор = Ложь;

    НачатьПомещениеФайлов(ОписаниеОповещения, , ДиалогОткрытияФайла, Истина, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	ПередЗакрытиемНаСервере();
	СохранитьНастройкиНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПередЗакрытиемНаСервере()
	
	Если ЗначениеЗаполнено(Объект.ПутьКФайлуНаСервере) Тогда
		Файл = Новый Файл(Объект.ПутьКФайлуНаСервере);
		Если Файл.Существует() Тогда
			УдалитьФайлы(Объект.ПутьКФайлуНаСервере);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыборФайлаRk(ПомещенныеФайлы, ДополнительныеПараметры) Экспорт

    Если ПомещенныеФайлы = Неопределено Тогда
        Возврат;
    КонецЕсли;

	Для каждого ПереданныйФайл Из ПомещенныеФайлы Цикл
		
        Адрес = ПереданныйФайл.Хранение;
		Объект.НазваниеФайла = ПереданныйФайл.ПолноеИмя;
		
    КонецЦикла;
    
    RkНаСервере(Адрес);

КонецПроцедуры

&НаСервере
Процедура RkНаСервере(Адрес)
    
    ФайлДляЗагрузки = Новый ХранилищеЗначения(ПолучитьИзВременногоХранилища(Адрес));
    Объект.ПутьКФайлуНаСервере = ПолучитьИмяВременногоФайла("xlsx");
    ФайлДляЗагрузки = ФайлДляЗагрузки.Получить();
    ФайлДляЗагрузки.Записать(Объект.ПутьКФайлуНаСервере);
         
КонецПроцедуры

&НаКлиенте
Процедура ПрочитатьФайл(Команда)

	
	//Отказ = ЗагрузитьМатериалыВСтроительнуюРаботуНаСервере();
	
	ТабличныйДокумент = ЗагрузитьМатериалыВСтроительнуюРаботуНаСервере();
	
	ТабличныйДокумент.Показать();
	
	//Если НЕ Отказ Тогда
		УдалитьФайлы(Объект.ПутьКФайлуНаСервере);
	//КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаСервере()
	
	//Проверить соответствие всех единиц измерений
	ЭтоУспех = ВернутьРезультатПроверкиЗаполненияЕдиницИзмерения();
	
	ЭтоУспех = ВернутьРезультатПроверкиЗаполненияРеквизитовВНастройке(ЭтоУспех);
	
	ЭтоУспех = ВернутьРезультатПроверкиСоответствияЕдиницИзмеренияНоменклатурыИзФайлаНоменклатуреБазы(ЭтоУспех);
	
	Если НЕ ЭтоУспех Тогда
		Возврат;
	КонецЕсли;
	
	ОбработатьДанныеСоответствияПоНоменклатуре();
	ЗаполнитьНоменклатуруВСоответствии();
	СоздатьСтроительнуюРаботуИЗаполнитьМатериалы();
	
КонецПроцедуры

&НаСервере
Функция ВернутьРезультатПроверкиСоответствияЕдиницИзмеренияНоменклатурыИзФайлаНоменклатуреБазы(ЭтоУспех)
		
	Результат = Истина;
	
	Запрос = Новый Запрос();
	
	Запрос.Текст = ВернутьТекстСоответствияЕдиницИзмеренияНоменклатурыИзФайлаНоменклатуреБазы();
	
	Запрос.УстановитьПараметр("ТЗ_СоответствиеПоНоменклатуре", 	Объект.СоответствиеПоНоменклатуре.Выгрузить());
	Запрос.УстановитьПараметр("ТЗ_СоответствиеЕдиницИзмерений", Объект.СоответствиеЕдиницИзмерений.Выгрузить());
	Запрос.УстановитьПараметр("ТЧМатериалыИзФайла", 			Объект.ТЧМатериалыИзФайла.Выгрузить());
	РезультатЗапроса = Запрос.Выполнить();

	
	Результат = РезультатЗапроса.Пустой();
	
	Выборка = РезультатЗапроса.Выбрать();
	//@skip-warning
	ТЗ 		= РезультатЗапроса.Выгрузить();
	
	Пока Выборка.Следующий() Цикл
	
		Сообщить(Выборка.НоменклатураСтрокой + " имеет единицу измерения " + Выборка.ЕдиницаИзмеренияСтрокой + ", а в базе " + Выборка.ЕдиницаИзмерения);	
	
	КонецЦикла;
	
	
		
	Если ЭтоУспех = Истина И Результат = Ложь Тогда
	
		ЭтоУспех = Ложь;
			
	КонецЕсли;
	
	Возврат ЭтоУспех;
	
КонецФункции

&НаСервере
Функция ВернутьТекстСоответствияЕдиницИзмеренияНоменклатурыИзФайлаНоменклатуреБазы()
	
	Возврат "ВЫБРАТЬ 
	|	ТЧМатериалыИзФайла.НоменклатураСтрокой КАК НоменклатураСтрокой,
	|	ТЧМатериалыИзФайла.ЕдиницаИзмеренияСтрокой КАК ЕдиницаИзмеренияСтрокой,
	|	ТЧМатериалыИзФайла.Количество КАК Количество
	|ПОМЕСТИТЬ ВТ_ТЧМатериалыИзФайла
	|ИЗ
	|	&ТЧМатериалыИзФайла КАК ТЧМатериалыИзФайла
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ_СоответствиеПоНоменклатуре.Номенклатура,
	|	ТЗ_СоответствиеПоНоменклатуре.НоменклатураСтрокой
	|ПОМЕСТИТЬ ВТ_ТЗ_СоответствиеПоНоменклатуре
	|ИЗ
	|	&ТЗ_СоответствиеПоНоменклатуре КАК ТЗ_СоответствиеПоНоменклатуре
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмеренияСтрокой КАК ЕдиницаИзмеренияСтрокой,
	|	ТЗ_СоответствиеЕдиницИзмерений.КоэфициентПереводаКБазовой КАК КоэфициентПереводаКБазовой
	|ПОМЕСТИТЬ ВТ_ТЗ_СоответствиеЕдиницИзмерений
	|ИЗ
	|	&ТЗ_СоответствиеЕдиницИзмерений КАК ТЗ_СоответствиеЕдиницИзмерений
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|//
	|Выбрать различные
	|	ВТ_ТЧМатериалыИзФайла.НоменклатураСтрокой,
	|	ВТ_ТЧМатериалыИзФайла.ЕдиницаИзмеренияСтрокой,
	|	ВТ_ТЗ_СоответствиеПоНоменклатуре.Номенклатура,
	|	ВТ_ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмерения
	|ИЗ
	|	ВТ_ТЧМатериалыИзФайла КАК ВТ_ТЧМатериалыИзФайла
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ТЗ_СоответствиеПоНоменклатуре КАК ВТ_ТЗ_СоответствиеПоНоменклатуре
	|		ПО ВТ_ТЧМатериалыИзФайла.НоменклатураСтрокой = ВТ_ТЗ_СоответствиеПоНоменклатуре.НоменклатураСтрокой
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ТЗ_СоответствиеЕдиницИзмерений КАК ВТ_ТЗ_СоответствиеЕдиницИзмерений
	|		ПО ВТ_ТЧМатериалыИзФайла.ЕдиницаИзмеренияСтрокой = ВТ_ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмеренияСтрокой
	|ГДЕ
	|	НЕ ВТ_ТЗ_СоответствиеПоНоменклатуре.Номенклатура = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
	|	И ВТ_ТЗ_СоответствиеПоНоменклатуре.Номенклатура.ЕдиницаИзмерения <> ВТ_ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмерения";
	
КонецФункции


Функция ВернутьТекстЗапросаНоменклатурыИЕдиницИзмеренияИзБазы()
	
	Возврат "ВЫБРАТЬ
	|	ТЧМатериалыИзФайла.НоменклатураСтрокой КАК НоменклатураСтрокой,
	|	ТЧМатериалыИзФайла.ЕдиницаИзмеренияСтрокой КАК ЕдиницаИзмеренияСтрокой,
	|	ТЧМатериалыИзФайла.Количество КАК Количество
	|ПОМЕСТИТЬ ВТ_ТЧМатериалыИзФайла
	|ИЗ
	|	&ТЧМатериалыИзФайла КАК ТЧМатериалыИзФайла
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ_СоответствиеПоНоменклатуре.Номенклатура,
	|	ТЗ_СоответствиеПоНоменклатуре.НоменклатураСтрокой
	|ПОМЕСТИТЬ ВТ_ТЗ_СоответствиеПоНоменклатуре
	|ИЗ
	|	&ТЗ_СоответствиеПоНоменклатуре КАК ТЗ_СоответствиеПоНоменклатуре
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмеренияСтрокой КАК ЕдиницаИзмеренияСтрокой,
	|	ТЗ_СоответствиеЕдиницИзмерений.КоэфициентПереводаКБазовой КАК КоэфициентПереводаКБазовой
	|ПОМЕСТИТЬ ВТ_ТЗ_СоответствиеЕдиницИзмерений
	|ИЗ
	|	&ТЗ_СоответствиеЕдиницИзмерений КАК ТЗ_СоответствиеЕдиницИзмерений
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|//
	|Выбрать 
	|	ВТ_ТЧМатериалыИзФайла.НоменклатураСтрокой,
	|	ВТ_ТЧМатериалыИзФайла.ЕдиницаИзмеренияСтрокой,
	|	ВТ_ТЗ_СоответствиеПоНоменклатуре.Номенклатура,
	|	ВТ_ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмерения,
	|	ВТ_ТЧМатериалыИзФайла.Количество * ВТ_ТЗ_СоответствиеЕдиницИзмерений.КоэфициентПереводаКБазовой КАК Количество
	|ИЗ
	|	ВТ_ТЧМатериалыИзФайла КАК ВТ_ТЧМатериалыИзФайла
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ТЗ_СоответствиеПоНоменклатуре КАК ВТ_ТЗ_СоответствиеПоНоменклатуре
	|		ПО ВТ_ТЧМатериалыИзФайла.НоменклатураСтрокой = ВТ_ТЗ_СоответствиеПоНоменклатуре.НоменклатураСтрокой
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ТЗ_СоответствиеЕдиницИзмерений КАК ВТ_ТЗ_СоответствиеЕдиницИзмерений
	|		ПО ВТ_ТЧМатериалыИзФайла.ЕдиницаИзмеренияСтрокой = ВТ_ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмеренияСтрокой";
	
КонецФункции

&НаСервере
Функция ВернутьРезультатПроверкиЗаполненияРеквизитовВНастройке(ЭтоУспех)
	
	Если НЕ ЗначениеЗаполнено(Объект.ГруппаАналитическогоУчета) Тогда
	
		Сообщить("Укажите группу аналитического учета");
		Результат = Ложь;
		
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(Объект.ВидНоменклатуры) Тогда
	
		Сообщить("Укажите Вид номенклатуры");
		Результат = Ложь;
		
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(Объект.ГруппаФинансовогоУчета) Тогда
	
		Сообщить("Укажите группу финансового учета");
		Результат = Ложь;
		
	КонецЕсли;
	Если ЭтоУспех = Истина И Результат = Ложь Тогда
	
		ЭтоУспех = Ложь;
			
	КонецЕсли;
	
	Возврат ЭтоУспех;
	
КонецФункции

&НаСервере
Процедура СоздатьСтроительнуюРаботуИЗаполнитьМатериалы()
	


	НовыйЭлементСтроительнаяРабота 							= Справочники.УСОERP_СтроительныеРаботы.СоздатьЭлемент();
	
	НовыйЭлементСтроительнаяРабота.Наименование 			= Объект.СтроительнаяРаботаСтрокой;
	НовыйЭлементСтроительнаяРабота.КраткоеНаименование 		= Объект.СтроительнаяРаботаСтрокой;
	НовыйЭлементСтроительнаяРабота.Владелец 				= Объект.ВидСценария;
	НовыйЭлементСтроительнаяРабота.ВидРабот 				= Справочники.УСОERP_ВидыРабот.ПустаяСсылка();
	НовыйЭлементСтроительнаяРабота.ГрафикРаботы				= Объект.ГрафикРабот;	
	НовыйЭлементСтроительнаяРабота.СуммарнаяРабота 			= Ложь;
	
	НовыйЭлементСтроительнаяРабота.НомерРаботыВУровнеСтрокой = 1;
	
	Запрос = Новый Запрос();
	
	Запрос.Текст = ВернутьТекстЗапросаНоменклатурыИЕдиницИзмеренияИзБазы();
	Запрос.УстановитьПараметр("ТЗ_СоответствиеПоНоменклатуре", 	Объект.СоответствиеПоНоменклатуре.Выгрузить());
	Запрос.УстановитьПараметр("ТЗ_СоответствиеЕдиницИзмерений", Объект.СоответствиеЕдиницИзмерений.Выгрузить());
	Запрос.УстановитьПараметр("ТЧМатериалыИзФайла", 			Объект.ТЧМатериалыИзФайла.Выгрузить());
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
	
		НоваяСтрока 									= НовыйЭлементСтроительнаяРабота.Материалы.Добавить();
		НоваяСтрока.Номенклатура  						= Выборка.Номенклатура;
		НоваяСтрока.КоличествоНаЕдиницуОбъема 			= Выборка.Количество;
		НоваяСтрока.КоличествоНаОбъемРаботы 			= Выборка.Количество;
		НоваяСтрока.КоличествоУпаковокНаЕдиницуОбъема 	= Выборка.Количество;
		НоваяСтрока.КоличествоУпаковокНаОбъемРаботы 	= Выборка.Количество;
		
	КонецЦикла;
	
	НовыйЭлементСтроительнаяРабота.ОбъемРаботы  = 1;
	НовыйЭлементСтроительнаяРабота.ЕдиницаОбъема = Справочники.УпаковкиЕдиницыИзмерения.НайтиПоНаименованию("шт");
	НовыйЭлементСтроительнаяРабота.ЕдиницаЗадержки = Перечисления.ЕдиницыИзмеренияВремени.День;
	НовыйЭлементСтроительнаяРабота.Длительность = 1;
	НовыйЭлементСтроительнаяРабота.ЕдиницаДлительности = Перечисления.ЕдиницыИзмеренияВремени.День;
	
	НовыйЭлементСтроительнаяРабота.ДатаНачала 		= Объект.НачалоРабот;
	НовыйЭлементСтроительнаяРабота.ДатаОкончания 	= Объект.ОкончаниеРабот;
	//НовыйЭлементСтроительнаяРабота.ЕстьПредшественники = Ложь;
	//ДатаНачала
	//ДатаОкончания
	//*-Собрать в единую таблицу застыкованные позиции номенклатуры и единицы измерения,
	//Заполнить их
	
	НовыйЭлементСтроительнаяРабота.Записать();
	
КонецПроцедуры

&НаСервере
Функция ВернутьРезультатПроверкиЗаполненияЕдиницИзмерения()
	
	Отбор = Новый Структура("ЕдиницаИзмерения", Справочники.УпаковкиЕдиницыИзмерения.ПустаяСсылка());
	Строки = Объект.СоответствиеЕдиницИзмерений.НайтиСтроки(Отбор);
	Результат = Строки.Количество() = 0;
	Если НЕ Результат Тогда
		Сообщить("Не заполнены соответствия единицы измерения");
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьНоменклатуруВСоответствии()
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = ВернутьТекстЗапросаДляПоискаОтсутствующейНоменклатуры();

	Запрос.УстановитьПараметр("ТЗ_СоответствиеПоНоменклатуре", Объект.СоответствиеПоНоменклатуре.Выгрузить());
	Запрос.УстановитьПараметр("ТЗ_СоответствиеЕдиницИзмерений", Объект.СоответствиеЕдиницИзмерений.Выгрузить());
	Запрос.УстановитьПараметр("ТЧМатериалыИзФайла", Объект.ТЧМатериалыИзФайла.Выгрузить());
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	ТЗ = Результат.Выгрузить();
	
	
	//Создаем пока только отсутствующую номенклатуру
	//XXX: ОЧЕНЬ ВАЖНО добавить проверку на несоответствие единиц измерения в справочнике номенклатуры и загружаемом файле.
	//такое грузить нельзя, поскольку не ясно какие единицы измерения.
	//Думаю, что надо перепроверить это после создания отсутствующей номенклатуры
	
	
	
	Пока Выборка.Следующий() Цикл
		
		//НачатьТранзакцию();
		НоваяНоменклатура 								= Справочники.Номенклатура.СоздатьЭлемент();
		НоваяНоменклатура.Наименование 					= Выборка.НоменклатураСтрокой;
		НоваяНоменклатура.НаименованиеПолное 			= Выборка.НоменклатураСтрокой;
		НоваяНоменклатура.ЕдиницаИзмерения 				= Выборка.ЕдиницаИзмерения;
		НоваяНоменклатура.ЕдиницаДляОтчетов 			= Выборка.ЕдиницаИзмерения;
		НоваяНоменклатура.КоэффициентЕдиницыДляОтчетов 	= 1;
		НоваяНоменклатура.ГруппаАналитическогоУчета 	= Объект.ГруппаАналитическогоУчета;
		НоваяНоменклатура.ВидНоменклатуры 				= Объект.ВидНоменклатуры;
		НоваяНоменклатура.ГруппаФинансовогоУчета 		= Объект.ГруппаФинансовогоУчета;
		НоваяНоменклатура.ИспользованиеХарактеристик 	= Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.НеИспользовать;
		НоваяНоменклатура.Качество 						= Перечисления.ГрадацииКачества.Новый;
		НоваяНоменклатура.СтавкаНДС 					= Перечисления.СтавкиНДС.НДС20;
		НоваяНоменклатура.ТипНоменклатуры 				= Перечисления.ТипыНоменклатуры.Товар;
		НоваяНоменклатура.ОсобенностьУчета 				= Перечисления.ОсобенностиУчетаНоменклатуры.БезОсобенностейУчета;
		НоваяНоменклатура.ВариантОформленияПродажи		= Перечисления.ВариантыОформленияПродажи.РеализацияТоваровУслуг;
		Если Выборка.ЕдиницаИзмерения.ТипИзмеряемойВеличины = Перечисления.ТипыИзмеряемыхВеличин.Вес Тогда
			
			НоваяНоменклатура.ВесЕдиницаИзмерения  				= Выборка.ЕдиницаИзмерения;
			НоваяНоменклатура.ВесЗнаменатель 					= 1;
			НоваяНоменклатура.ВесИспользовать 					= Истина;
			НоваяНоменклатура.ВесМожноУказыватьВДокументах 		= Истина;
			НоваяНоменклатура.ВесЧислитель 						= 1;
					
		ИначеЕсли Выборка.ЕдиницаИзмерения.ТипИзмеряемойВеличины = Перечисления.ТипыИзмеряемыхВеличин.Объем Тогда
		
			НоваяНоменклатура.ОбъемЕдиницаИзмерения  			= Выборка.ЕдиницаИзмерения;
			НоваяНоменклатура.ОбъемЗнаменатель 					= 1;
			НоваяНоменклатура.ОбъемИспользовать 				= Истина;
			НоваяНоменклатура.ОбъемМожноУказыватьВДокументах 	= Истина;
			НоваяНоменклатура.ОбъемЧислитель = 1;
		
		ИначеЕсли Выборка.ЕдиницаИзмерения.ТипИзмеряемойВеличины = Перечисления.ТипыИзмеряемыхВеличин.Площадь Тогда
			
			НоваяНоменклатура.ПлощадьЕдиницаИзмерения  			= Выборка.ЕдиницаИзмерения;
			НоваяНоменклатура.ПлощадьЗнаменатель 				= 1;
			НоваяНоменклатура.ПлощадьИспользовать 				= Истина;
			НоваяНоменклатура.ПлощадьМожноУказыватьВДокументах 	= Истина;
			НоваяНоменклатура.ПлощадьЧислитель 					= 1;
					
		КонецЕсли;
		
		НоваяНоменклатура.Записать();	
	
		//ОтменитьТранзакцию();
	КонецЦикла;
	
	
	
КонецПроцедуры

&НаСервере
Функция ВернутьТекстЗапросаДляПоискаОтсутствующейНоменклатуры()
	
	Возврат "ВЫБРАТЬ
	|	ТЧМатериалыИзФайла.НоменклатураСтрокой КАК НоменклатураСтрокой,
	|	ТЧМатериалыИзФайла.ЕдиницаИзмеренияСтрокой КАК ЕдиницаИзмеренияСтрокой,
	|	ТЧМатериалыИзФайла.Количество КАК Количество
	|ПОМЕСТИТЬ ВТ_ТЧМатериалыИзФайла
	|ИЗ
	|	&ТЧМатериалыИзФайла КАК ТЧМатериалыИзФайла
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ_СоответствиеПоНоменклатуре.Номенклатура,
	|	ТЗ_СоответствиеПоНоменклатуре.НоменклатураСтрокой
	|ПОМЕСТИТЬ ВТ_ТЗ_СоответствиеПоНоменклатуре
	|ИЗ
	|	&ТЗ_СоответствиеПоНоменклатуре КАК ТЗ_СоответствиеПоНоменклатуре
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмеренияСтрокой КАК ЕдиницаИзмеренияСтрокой,
	|	ТЗ_СоответствиеЕдиницИзмерений.КоэфициентПереводаКБазовой КАК КоэфициентПереводаКБазовой
	|ПОМЕСТИТЬ ВТ_ТЗ_СоответствиеЕдиницИзмерений
	|ИЗ
	|	&ТЗ_СоответствиеЕдиницИзмерений КАК ТЗ_СоответствиеЕдиницИзмерений
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|//
	|Выбрать различные
	|	ВТ_ТЧМатериалыИзФайла.НоменклатураСтрокой,
	|	ВТ_ТЗ_СоответствиеПоНоменклатуре.Номенклатура,
	|	ВТ_ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмерения
	|ИЗ
	|	ВТ_ТЧМатериалыИзФайла КАК ВТ_ТЧМатериалыИзФайла
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ТЗ_СоответствиеПоНоменклатуре КАК ВТ_ТЗ_СоответствиеПоНоменклатуре
	|		ПО ВТ_ТЧМатериалыИзФайла.НоменклатураСтрокой = ВТ_ТЗ_СоответствиеПоНоменклатуре.НоменклатураСтрокой
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ТЗ_СоответствиеЕдиницИзмерений КАК ВТ_ТЗ_СоответствиеЕдиницИзмерений
	|		ПО ВТ_ТЧМатериалыИзФайла.ЕдиницаИзмеренияСтрокой = ВТ_ТЗ_СоответствиеЕдиницИзмерений.ЕдиницаИзмеренияСтрокой
	|ГДЕ
	|	ВТ_ТЗ_СоответствиеПоНоменклатуре.Номенклатура = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)";
	
КонецФункции

&НаСервере
Функция ЗагрузитьМатериалыВСтроительнуюРаботуНаСервере()
	
	ТабДок = Новый ТабличныйДокумент;
	Попытка
		ТабДок.Прочитать(Объект.ПутьКФайлуНаСервере, СпособЧтенияЗначенийТабличногоДокумента.Значение);
	Исключение
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = ОписаниеОшибки();
		Сообщение.Сообщить();
		Возврат Истина;
	КонецПопытки;
	
	НомерСтроки = 15;
	КолСтр = ТабДок.ВысотаТаблицы;
	
	Объект.ТЧМатериалыИзФайла.Очистить();
	Объект.СтроительнаяРаботаСтрокой 	= СтрЗаменить(СокрЛП(ТабДок.ПолучитьОбласть("R7C2").ТекущаяОбласть.Текст), ",", "");
	Объект.НачалоРабот 					= Дата(Прав(ТабДок.ПолучитьОбласть("R15C8").ТекущаяОбласть.Текст, 4) + Сред(ТабДок.ПолучитьОбласть("R15C8").ТекущаяОбласть.Текст, 4, 2) + Лев(ТабДок.ПолучитьОбласть("R15C8").ТекущаяОбласть.Текст,2));
	Объект.ОкончаниеРабот 				= Дата(Прав(ТабДок.ПолучитьОбласть("R15C9").ТекущаяОбласть.Текст, 4) + Сред(ТабДок.ПолучитьОбласть("R15C9").ТекущаяОбласть.Текст, 4, 2) + Лев(ТабДок.ПолучитьОбласть("R15C9").ТекущаяОбласть.Текст,2));
		
	Для Сч = НомерСтроки по КолСтр Цикл
		
		НоменклатураСтрокой 	= ТабДок.ПолучитьОбласть("R" + Формат(Сч, "ЧГ=0") + "C3").ТекущаяОбласть.Текст;
		ЕдиницыИзмеренияСтрокой = СокрЛП(ТабДок.ПолучитьОбласть("R" + Формат(Сч, "ЧГ=0") + "C4").ТекущаяОбласть.Текст);
		Количество		 		= Формат(ТабДок.ПолучитьОбласть("R" + Формат(Сч, "ЧГ=0") + "C5").ТекущаяОбласть.Текст,"ЧГ=0");
		
		Если Не ЗначениеЗаполнено(НоменклатураСтрокой) Тогда
			Прервать;		
		КонецЕсли;
		
		СтрокаДляДобавления 						= Объект.ТЧМатериалыИзФайла.Добавить();
		СтрокаДляДобавления.НоменклатураСтрокой 	= НоменклатураСтрокой;
		СтрокаДляДобавления.ЕдиницаИзмеренияСтрокой = ЕдиницыИзмеренияСтрокой;
		СтрокаДляДобавления.Количество 				= Число(Количество);		
		
		Если Сч > 50 Тогда
			
			Прервать;
		
		КонецЕсли;
		
			
	КонецЦикла;
	
	
	ОбработатьДанныеСоответствияПоНоменклатуре();	
	ОбработатьДанныеСоответствияЕдиницИзмерения();
	
	

		
	Возврат ТабДок;
	
КонецФункции

&НаСервере
Процедура ОбработатьДанныеСоответствияЕдиницИзмерения()
	
	ТЗ = Объект.ТЧМатериалыИзФайла.Выгрузить(,"ЕдиницаИзмеренияСтрокой");
	ТЗ.Свернуть("ЕдиницаИзмеренияСтрокой");
	
	ТЗ2 = Объект.СоответствиеЕдиницИзмерений.Выгрузить();
	
	Запрос = Новый Запрос("
	|
	|ВЫБРАТЬ
	|	ТЗ.ЕдиницаИзмеренияСтрокой
	|ПОМЕСТИТЬ ВТ_ТЗ
	|ИЗ
	|	&ТЗ КАК ТЗ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ2.ЕдиницаИзмеренияСтрокой,
	|	ТЗ2.ЕдиницаИзмерения КАК ЕдиницаИзмерения
	|ПОМЕСТИТЬ ВТ_ТЗ2
	|ИЗ
	|	&ТЗ2 КАК ТЗ2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ТЗ.ЕдиницаИзмеренияСтрокой,
	|	МАКСИМУМ(УпаковкиЕдиницыИзмерения.Ссылка) КАК Ссылка
	|ПОМЕСТИТЬ ВТ_ПодобранныеПоНаименованию
	|ИЗ
	|	ВТ_ТЗ КАК ВТ_ТЗ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.УпаковкиЕдиницыИзмерения КАК УпаковкиЕдиницыИзмерения
	|		ПО УпаковкиЕдиницыИзмерения.Наименование = ВТ_ТЗ.ЕдиницаИзмеренияСтрокой
	|СГРУППИРОВАТЬ ПО
	|	ВТ_ТЗ.ЕдиницаИзмеренияСтрокой
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ТЗ.ЕдиницаИзмеренияСтрокой,
	|	ЗНАЧЕНИЕ(Справочник.УпаковкиЕдиницыИзмерения.ПустаяСсылка) КАК ЕдиницаИзмерения
	|ПОМЕСТИТЬ ВТ_ТЗ_Объединенное
	|ИЗ
	|	ВТ_ТЗ КАК ВТ_ТЗ
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВТ_ТЗ2.ЕдиницаИзмеренияСтрокой,
	|	ВТ_ТЗ2.ЕдиницаИзмерения КАК ЕдиницаИзмерения
	|ИЗ
	|	ВТ_ТЗ2 КАК ВТ_ТЗ2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ТЗ_Объединенное.ЕдиницаИзмеренияСтрокой,
	|	МАКСИМУМ(ВТ_ТЗ_Объединенное.ЕдиницаИзмерения) КАК ЕдиницаИзмерения
	|ПОМЕСТИТЬ ВТ_ПодготовленныйИзЗагрузки
	|ИЗ
	|	ВТ_ТЗ_Объединенное КАК ВТ_ТЗ_Объединенное
	|СГРУППИРОВАТЬ ПО
	|	ВТ_ТЗ_Объединенное.ЕдиницаИзмеренияСтрокой
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ПодготовленныйИзЗагрузки.ЕдиницаИзмеренияСтрокой,
	|	ВЫБОР
	|		КОГДА НЕ ВТ_ПодготовленныйИзЗагрузки.ЕдиницаИзмерения = ЗНАЧЕНИЕ(СПРАВОЧНИК.УпаковкиЕдиницыИзмерения.ПустаяСсылка)
	|			ТОГДА ВТ_ПодготовленныйИзЗагрузки.ЕдиницаИзмерения
	|		ИНАЧЕ ВТ_ПодобранныеПоНаименованию.Ссылка
	|	КОНЕЦ КАК ЕдиницаИзмерения
	|ИЗ
	|	ВТ_ПодготовленныйИзЗагрузки КАК ВТ_ПодготовленныйИзЗагрузки
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ПодобранныеПоНаименованию КАК ВТ_ПодобранныеПоНаименованию
	|		ПО ВТ_ПодобранныеПоНаименованию.ЕдиницаИзмеренияСтрокой = ВТ_ПодготовленныйИзЗагрузки.ЕдиницаИзмеренияСтрокой");
	
	Запрос.УстановитьПараметр("ТЗ", ТЗ);
	Запрос.УстановитьПараметр("ТЗ2", ТЗ2);
	
	Объект.СоответствиеЕдиницИзмерений.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

&НаСервере
Процедура ОбработатьДанныеСоответствияПоНоменклатуре()
	
	ТЗ = Объект.ТЧМатериалыИзФайла.Выгрузить(,"НоменклатураСтрокой");
	ТЗ.Свернуть("НоменклатураСтрокой");
	
	ТЗ2 = Объект.СоответствиеПоНоменклатуре.Выгрузить();
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	ТЗ.НоменклатураСтрокой
	|ПОМЕСТИТЬ ВТ_ТЗ
	|ИЗ
	|	&ТЗ КАК ТЗ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТЗ2.НоменклатураСтрокой,
	|	ТЗ2.Номенклатура КАК Номенклатура
	|ПОМЕСТИТЬ ВТ_ТЗ2
	|ИЗ
	|	&ТЗ2 КАК ТЗ2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ТЗ.НоменклатураСтрокой,
	|	МАКСИМУМ(Номенклатура.Ссылка) КАК Ссылка
	|ПОМЕСТИТЬ ВТ_ПодобранныеПоНаименованию
	|ИЗ
	|	ВТ_ТЗ КАК ВТ_ТЗ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
	|		ПО Номенклатура.Наименование = ВТ_ТЗ.НоменклатураСтрокой
	|СГРУППИРОВАТЬ ПО
	|	ВТ_ТЗ.НоменклатураСтрокой
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ТЗ.НоменклатураСтрокой,
	|	ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка) КАК Номенклатура
	|ПОМЕСТИТЬ ВТ_ТЗ_Объединенное
	|ИЗ
	|	ВТ_ТЗ КАК ВТ_ТЗ
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВТ_ТЗ2.НоменклатураСтрокой,
	|	ВТ_ТЗ2.Номенклатура КАК Номенклатура
	|ИЗ
	|	ВТ_ТЗ2 КАК ВТ_ТЗ2
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ТЗ_Объединенное.НоменклатураСтрокой,
	|	МАКСИМУМ(ВТ_ТЗ_Объединенное.Номенклатура) КАК Номенклатура
	|ПОМЕСТИТЬ ВТ_ПодготовленныйИзЗагрузки
	|ИЗ
	|	ВТ_ТЗ_Объединенное КАК ВТ_ТЗ_Объединенное
	|СГРУППИРОВАТЬ ПО
	|	ВТ_ТЗ_Объединенное.НоменклатураСтрокой
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ПодготовленныйИзЗагрузки.НоменклатураСтрокой,
	|	ВЫБОР
	|		КОГДА НЕ ВТ_ПодготовленныйИзЗагрузки.Номенклатура = ЗНАЧЕНИЕ(СПРАВОЧНИК.Номенклатура.ПустаяСсылка)
	|			ТОГДА ВТ_ПодготовленныйИзЗагрузки.Номенклатура
	|		ИНАЧЕ ВТ_ПодобранныеПоНаименованию.Ссылка
	|	КОНЕЦ КАК Номенклатура
	|ИЗ
	|	ВТ_ПодготовленныйИзЗагрузки КАК ВТ_ПодготовленныйИзЗагрузки
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ПодобранныеПоНаименованию КАК ВТ_ПодобранныеПоНаименованию
	|		ПО ВТ_ПодобранныеПоНаименованию.НоменклатураСтрокой = ВТ_ПодготовленныйИзЗагрузки.НоменклатураСтрокой");
	
	Запрос.УстановитьПараметр("ТЗ", ТЗ);
	Запрос.УстановитьПараметр("ТЗ2", ТЗ2);
	
	Объект.СоответствиеПоНоменклатуре.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПриОткрытииНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПриОткрытииНаСервере()
	
	Результат = ХранилищеСистемныхНастроек.Загрузить( "ЗагрузкаНачальныхДанных", "СоответствиеЕдиницИзмерений");
	Если НЕ Результат = Неопределено Тогда 
		Объект.СоответствиеЕдиницИзмерений.Загрузить(Результат);
	КонецЕсли;
	Результат = ХранилищеСистемныхНастроек.Загрузить( "ЗагрузкаНачальныхДанных", "СоответствиеПоНоменклатуре");
	Если НЕ Результат = Неопределено Тогда 
		Объект.СоответствиеПоНоменклатуре.Загрузить(Результат);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура СохранитьНастройкиНаСервере()
	ХранилищеСистемныхНастроек.Сохранить( "ЗагрузкаНачальныхДанных", "СоответствиеЕдиницИзмерений", Объект.СоответствиеЕдиницИзмерений.Выгрузить());
	ХранилищеСистемныхНастроек.Сохранить( "ЗагрузкаНачальныхДанных", "СоответствиеПоНоменклатуре", Объект.СоответствиеПоНоменклатуре.Выгрузить());
КонецПроцедуры

&НаКлиенте
Процедура НазваниеФайлаОткрытие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

