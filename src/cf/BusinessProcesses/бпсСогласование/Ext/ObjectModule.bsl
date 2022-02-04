﻿
Процедура СтартПередСтартом(ТочкаМаршрутаБизнесПроцесса, Отказ)
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	Конецесли;
	
	ЗаполнитьАвто(Отказ);	
	
	//ПроверитьУказаныЛиАдресаЭлектроннойПочтыДляВсехУчастников(Отказ);
	
	//Записать();
	
	Если НЕ Отказ Тогда
		ОтправитьУведомление(Перечисления.бпсСобытия.ПередСтартом);
	Конецесли;
	
	ДополнительныеСвойства.Вставить("ЭтоСтартПроцесса",Истина);	
	
	ВыполнитьДействиеПередСтартом(Отказ);
КонецПроцедуры

Процедура ЗаполнитьАвто(Отказ) Экспорт
	Если НЕ ЗначениеЗаполнено(Инициатор) Тогда
		Инициатор = ПараметрыСеанса.ТекущийПользователь;
	Конецесли;
	ПротоколФормированияЛистаСогласования = "";
	ЗаполнитьЛистСогласования(Отказ);
	ЗаполнитьДействия(Отказ);
КонецПроцедуры //ЗаполнитьАвто(Отказ)

Процедура ОтправитьУведомление(СобытиеДляОтправкиУведомления) Экспорт
	
	ВТПользователиДляУведомления = ПолучитьВТПользователиДляУведомления(СобытиеДляОтправкиУведомления);
	
	Если ВТПользователиДляУведомления.Количество() = 0 Тогда
		Возврат;
	Конецесли;
	
	РезультатФункции = СформироватьТекстИТемуУведомленияПоУсловиюОтправки(СобытиеДляОтправкиУведомления);
	Если РезультатФункции.Отказ Тогда
		Возврат;
	Конецесли;	
	Для каждого СтрокаВТПользователиДляУведомления из ВТПользователиДляУведомления цикл
		Если СтрокаВТПользователиДляУведомления.УведомлятьПочтой Тогда
			
			ПользовательДляОтправки = СтрокаВТПользователиДляУведомления.Пользователь; 
			
			ПараметрыПисьма = Новый Структура;
			ПараметрыПисьма.Вставить("ПользовательДляОтправки", ПользовательДляОтправки);
			ПараметрыПисьма.Вставить("Тело", РезультатФункции.ТекстУведомления);
			ПараметрыПисьма.Вставить("Тема", РезультатФункции.ТемаУведомления);
			ПараметрыПисьма.Вставить("ОбъектБД", ОбъектБД);
			ПараметрыПисьма.Вставить("ОтправлятьУведомлениеТелеграмм", Ложь);
			
			ИдентификаторСообщения = РегистрыСведений.бпсСообщения.ДобавитьСообщение(ПараметрыПисьма);			
		Конецесли;
		Если СтрокаВТПользователиДляУведомления.УведомлятьЗадачей Тогда
			СоздатьЗадачу(РезультатФункции.ТемаУведомления,СтрокаВТПользователиДляУведомления.Пользователь);				
		Конецесли;		
	Конеццикла;	
КонецПроцедуры //ОтправитьУведомление(Перечисления.бпсСобытия.ПриСтарте)

Функция ПолучитьВТПользователиДляУведомления(СобытиеДляОтправкиУведомления) Экспорт 
	
	ВТПользователиДляУведомления = ПользователиДляУведомления.ВыгрузитьКолонки();
	
	НомерПрохода = 1;
	
	Пока НомерПрохода <=2 Цикл
		ПараметрыОтбора=Новый Структура();
		Если НомерПрохода = 1 Тогда //В начале поищем пользователей для текущего номера очереди
			ПараметрыОтбора.Вставить("Очередь",ТекущийНомерОчереди);		
		Конецесли;
		Если НомерПрохода = 2 Тогда //отправлять без очереди проверка по условию отправки
			ПараметрыОтбора.Вставить("Очередь",0);		
		Конецесли;		
		ПараметрыОтбора.Вставить("Событие",СобытиеДляОтправкиУведомления);
		
		НайденныеСтроки = ПользователиДляУведомления.НайтиСтроки(ПараметрыОтбора);
		Для каждого СтрокаПользователиДляУведомления из НайденныеСтроки цикл
			Если ВТПользователиДляУведомления.Найти(СтрокаПользователиДляУведомления.Пользователь,"Пользователь") <> Неопределено Тогда
				Продолжить;
			Конецесли;
			СтрокаВТПользователиДляУведомления = ВТПользователиДляУведомления.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаВТПользователиДляУведомления,СтрокаПользователиДляУведомления);
		Конеццикла;		
		
		НомерПрохода = НомерПрохода + 1;
	Конеццикла;
	
	// При упрощенной системе уведомлений, если для текущей очереди в ТЧ: ЛистСогласования указано "УведомлятьПользователейПриВыполнении", 
	// тогда при выполнении задачи отправляется уведомление всем пользователям указанным в ТЧ: ПользователиДляУведомления
	Если УпрощеннаяСистемаУведомлений Тогда 
		//Если УсловиеОтправкиУведомления = Перечисления.бпсСобытия.ПриВыполненииЗадачиВОчереди Тогда
		//	ПараметрыОтбора=Новый Структура();
		//	ПараметрыОтбора.Вставить("Очередь",ТекущийНомерОчереди);
		//	НайденныеСтроки = ЛистСогласования.НайтиСтроки(ПараметрыОтбора);
		//	УведомлятьПользователейПриВыполнении = Ложь;
		//	Для каждого СтрокаЛистСогласования из НайденныеСтроки цикл
		//		Если СтрокаЛистСогласования.УведомлятьПользователейПриВыполнении Тогда
		//			УведомлятьПользователейПриВыполнении = Истина;	
		//		Конецесли;
		//	Конеццикла;
		//	Если НЕ УведомлятьПользователейПриВыполнении Тогда
		//		ВТПользователиДляУведомления.Очистить();	
		//	Конецесли
		//Конецесли;	
		Если СобытиеДляОтправкиУведомления = Перечисления.бпсСобытия.ПриЗавершении Тогда
			Если УведомитьИнициатораОЗавершении Тогда
				СтрокаВТПользователиДляУведомления = ВТПользователиДляУведомления.Добавить();
				СтрокаВТПользователиДляУведомления.Пользователь = Инициатор;
				СтрокаВТПользователиДляУведомления.Событие = СобытиеДляОтправкиУведомления;
				СтрокаВТПользователиДляУведомления.УведомлятьПочтой = Истина;
			Конецесли;
		Конецесли		
	Конецесли;
	Возврат ВТПользователиДляУведомления;
КонецФункции //

Функция СформироватьТекстИТемуУведомленияПоУсловиюОтправки(СобытиеДляОтправкиУведомления) Экспорт 
	Отказ = Ложь;
	Если СобытиеДляОтправкиУведомления = Перечисления.бпсСобытия.ПриЗавершении Тогда
		
		РезультатСогласования = ?(Согласовано, "Утверждена","Отклонена");
		ТемаУведомления  = "Уведомление 1С: согласование завершено"
			+ " Статус ["+РезультатСогласования+"]"
			+ " Объект ["+ОбъектБД +"]"
			;
		
		ТекстУведомления = "Уведомление 1С: согласование завершено" + Символы.ПС
			+ " Статус: ["+РезультатСогласования+"]" + Символы.ПС
			+ " Объект: ["+ОбъектБД +"]" + Символы.ПС
			+ " Предмет согласования: ["+ПредметСогласования+"]" + Символы.ПС
			+ " Тип: ["+ТипЗнч(ОбъектБД) +"]" + Символы.ПС
			;
		
		пТекстРецензий = ПолучитьТекстРецензий();
		Если ЗначениеЗаполнено(пТекстРецензий) Тогда
			ТекстУведомления = ТекстУведомления + пТекстРецензий;
		Конецесли;
		
	ИначеЕсли СобытиеДляОтправкиУведомления = Перечисления.бпсСобытия.ПриСтарте
		ИЛИ СобытиеДляОтправкиУведомления = Перечисления.бпсСобытия.ПередСтартом Тогда		
		пСтатус = ПредопределенноеЗначение("Справочник.бпсСтатусыОбъектов.Согласование_ВПроцессеСогласования");
		ТемаУведомления  = "Уведомление 1С: запущено согласование для "
			+ " объекта ["+ОбъектБД +"]"
			;
		ТекстУведомления = "Уведомление 1С: запущено согласование для " + Символы.ПС
			+ " Объекта: ["+ОбъектБД +"]" + Символы.ПС
			+ " Статус: ["+пСтатус+"]" + Символы.ПС
			+ " Предмет согласования: ["+ПредметСогласования+"]" + Символы.ПС
			+ " Тип: ["+ТипЗнч(ОбъектБД) +"]" + Символы.ПС
			;		
	ИначеЕсли СобытиеДляОтправкиУведомления = Перечисления.бпсСобытия.ПриВыполненииЗадачиВОчереди Тогда	
		ВТЛистСогласования = ЛистСогласования.Выгрузить(,"Очередь");		
		ВТЛистСогласования.Свернуть("Очередь","");
				
		ПараметрыОтбора=Новый Структура();
		ПараметрыОтбора.Вставить("Очередь",ТекущийНомерОчереди);
		РезультатВыполненияЗадачи = Истина;
		НайденныеСтроки = ЛистСогласования.НайтиСтроки(ПараметрыОтбора);
		Для каждого СтрокаНайденныеСтроки из НайденныеСтроки цикл
			Если НЕ СтрокаНайденныеСтроки.Согласовано Тогда
				РезультатВыполненияЗадачи = Ложь;
				Прервать;
			Конецесли;
		Конеццикла;
		КоличествоШаговДляСогласования = ВТЛистСогласования.Количество();
		пСтатус = ПредопределенноеЗначение("Справочник.бпсСтатусыОбъектов.Согласование_ВПроцессеСогласования");
		ТемаУведомления  = "Уведомление 1С:"
			+ " Выполнена задача шаг № "+ТекущийНомерОчереди+" из "+КоличествоШаговДляСогласования
			+ " Объект ["+ОбъектБД +"]"
			;
		
		ТекстРезультатВыполненияЗадачи = " с результатом """ + ?(РезультатВыполненияЗадачи, "согласовано","не согласовано")+"""";
		
		ТекстУведомления = "Уведомление 1С: Выполнена задача шаг № "+ТекущийНомерОчереди+" из "+КоличествоШаговДляСогласования
			+ ТекстРезультатВыполненияЗадачи + Символы.ПС
			+ " Объект: ["+ОбъектБД +"]" + Символы.ПС
			+ " Предмет согласования: ["+ПредметСогласования+"]" + Символы.ПС
			+ " Тип: ["+ТипЗнч(ОбъектБД) +"]" + Символы.ПС			
			;
	Иначе
		ВызватьИсключение "Ошибка! не задан алгоритм формирования уведомления, для условия: """+СобытиеДляОтправкиУведомления+"""";
		ТемаУведомления = "";
		ТекстУведомления = "";
		Отказ = Истина;
	Конецесли;
	
	//ТекстУведомления = ТекстУведомления + " 
	//	|
	//	|
	//	|
	//	|
	//	|_____________________________________________________________________
	//	|
	//	|Письмо сформировано автоматически. Пожалуйста, не отвечайте на него.
	//	|Информация о базе: ["+СтрокаСоединенияИнформационнойБазы()+"]
	//	|" 
	//	;
	РезультатФункции = Новый Структура();
	РезультатФункции.Вставить("ТемаУведомления",ТемаУведомления);
	РезультатФункции.Вставить("ТекстУведомления",ТекстУведомления);
	РезультатФункции.Вставить("Отказ",Отказ);
	Возврат РезультатФункции;
КонецФункции //СформироватьТекстИТемуПисьмаПоУсловиюОтправки()

Процедура СоздатьЗадачу(пНаименованиеЗадачи,пПользователь) Экспорт
	ЗадачаОбъект = Задачи.бпсЗадача.СоздатьЗадачу();
	ЗадачаОбъект.Пользователь = пПользователь;
	ЗадачаОбъект.Наименование = пНаименованиеЗадачи;
	ЗадачаОбъект.Дата = ТекущаяДата();
	ЗадачаОбъект.Записать();
КонецПроцедуры //СоздатьЗадачу(РезультатФункции.ТекстПисьма, РезультатФункции.ТемаПисьма,СтрокаВТПользователиДляУведомления.Пользователь)

Функция ПолучитьТекстРецензий() Экспорт
	ТекстРецензий = "";
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РегистрСведенийбпсЗадачиПоБизнесПроцессам.Очередь,
	|	РегистрСведенийбпсЗадачиПоБизнесПроцессам.Задача.ФактическаяДатаВыполнения КАК ДатаРецензии,
	|	РегистрСведенийбпсЗадачиПоБизнесПроцессам.Задача.РольАдресации КАК РольАдресации,
	|	РегистрСведенийбпсЗадачиПоБизнесПроцессам.Задача.ФактическийИсполнитель КАК Рецензент,
	|	РегистрСведенийбпсЗадачиПоБизнесПроцессам.Рецензия
	|ИЗ
	|	РегистрСведений.бпсЗадачиПоБизнесПроцессам КАК РегистрСведенийбпсЗадачиПоБизнесПроцессам
	|ГДЕ
	|	(ВЫРАЗИТЬ(РегистрСведенийбпсЗадачиПоБизнесПроцессам.Рецензия КАК СТРОКА(1))) <> """"
	|	И РегистрСведенийбпсЗадачиПоБизнесПроцессам.ВыводитьВОтчет
	|	И РегистрСведенийбпсЗадачиПоБизнесПроцессам.ИсходныйБизнесПроцесс = &ИсходныйБизнесПроцесс
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаРецензии";
	
	Запрос.УстановитьПараметр("ИсходныйБизнесПроцесс", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Возврат ТекстРецензий;
	Конецесли;
	
	ТекстРецензий = Символы.ПС+Символы.ПС+"РЕЦЕНЗИИ:"+Символы.ПС+Символы.ПС;
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл                                                                 
		ТекстРецензий = ТекстРецензий 
			+"Дата рецензии: " + Выборка.ДатаРецензии 
			+" Рецензент: ["+Выборка.Рецензент+"]"
			+" Роль: ["+Выборка.РольАдресации +"]:"
			+Символы.ПС
			+"Рецензия: "
			+Символы.ПС
			+" - "+СокрЛП(Выборка.Рецензия)+""
			+Символы.ПС + Символы.ПС;
	КонецЦикла;
	Возврат ТекстРецензий;
КонецФункции //ДобавитьВТексУведомленияРецензии(ТекстУведомления)

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	ТипЗнчДанныеЗаполнения = ТипЗнч(ДанныеЗаполнения);
	Отказ = Ложь;
	Если ТипЗнчДанныеЗаполнения = Тип("Структура") Тогда
		
		ОбъектБД = ДанныеЗаполнения.ОбъектБД;
		ПредметСогласования = ДанныеЗаполнения.ПредметСогласования;
		
		Инициатор = ПараметрыСеанса.ТекущийПользователь;
		
		Пояснение = СформироватьТекстПояснения(Отказ);
		
		УпрощеннаяСистемаУведомлений = ПредметСогласования.УпрощеннаяСистемаУведомлений;
		УведомитьИнициатораОЗавершении = ПредметСогласования.УведомитьИнициатораОЗавершении;
		РазрешеноПовторноеСогласование = ПредметСогласования.РазрешеноПовторноеСогласование;
		
		//ЗаполнитьЛистСогласования(Отказ);	
	Конецесли;
КонецПроцедуры

Функция СформироватьТекстПояснения(Отказ) Экспорт 
	ТекстПояснения = "Прошу согласовать: "+Символы.ПС
		+"ОбъектБД: ["+ОбъектБД+"]"+Символы.ПС
		+"Предмет согласования: ["+ПредметСогласования+"]";
	Возврат ТекстПояснения;
КонецФункции //СформироватьТекстПояснения()

Процедура ЗаполнитьЛистСогласования(Отказ) Экспорт
	Если Отказ Тогда
		Возврат;
	Конецесли;
	ПротоколФормированияЛистаСогласования = "";
	ТекущийНомерОчереди = 0;
	ПользователиДляУведомления.Очистить();
	ЛистСогласования.Очистить();
	
	Если УведомитьИнициатораОЗавершении Тогда
		СтрокаПользователиДляУведомления = ПользователиДляУведомления.Добавить();
		СтрокаПользователиДляУведомления.Очередь = 0;
		СтрокаПользователиДляУведомления.Пользователь = Инициатор;
		СтрокаПользователиДляУведомления.Событие = Перечисления.бпсСобытия.ПриЗавершении;
	Конецесли;
	ПараметрыОтбора = Новый Структура();
	ПараметрыОтбора.Вставить("КлючСтроки",0);
	НайденныеСтроки = ПредметСогласования.ПользователиДляУведомления.НайтиСтроки(ПараметрыОтбора);
	Для каждого СтрокаПредмет_ПользователиДляУведомления из НайденныеСтроки цикл
		СтрокаПользователиДляУведомления = ПользователиДляУведомления.Добавить();			
		ЗаполнитьЗначенияСвойств(СтрокаПользователиДляУведомления,СтрокаПредмет_ПользователиДляУведомления);
		СтрокаПользователиДляУведомления.Очередь = 0;
	Конеццикла;			

	КлючЗадачи = 1;
	Очередь = 1;
	Если ПредметСогласования.ОпределениеЛистаСогласования.Количество() > 0 Тогда
		ПротоколФормированияЛистаСогласования = "Протокол формирования листа согласования:"+Символы.ПС
			+"Объект согласования: ["+ОбъектБД+"]"+Символы.ПС
			+"Предмет согласования: ["+ПредметСогласования+"]"+Символы.ПС
			+Символы.ПС;
			;
	Конецесли;
	
	Пояснение = СформироватьТекстПояснения(Отказ);
	
	Для каждого СтрокаОпределениеЛистаСогласования из ПредметСогласования.ОпределениеЛистаСогласования цикл
		Согласователь = Неопределено;
		пУсловие = СтрокаОпределениеЛистаСогласования.Условие;
		ДопПараметры = Новый Структура();
		ДопПараметры.Вставить("ОбъектБД",ОбъектБД);
		ДопПараметры.Вставить("Условие",пУсловие);
		ДопПараметры.Вставить("РольАдресации",СтрокаОпределениеЛистаСогласования.РольАдресации);
		ДопПараметры.Вставить("ПропускатьЕслиНеЗаданАдресат",СтрокаОпределениеЛистаСогласования.ПропускатьЕслиНеЗаданАдресат);
		пУсловиеВыполнено = Справочники.бпсУсловия.УсловиеВыполнено(ДопПараметры,Отказ);
		Если НЕ пУсловиеВыполнено Тогда
			ПротоколФормированияЛистаСогласования = ПротоколФормированияЛистаСогласования 
				+ "Условие № "+СтрокаОпределениеЛистаСогласования.НомерСтроки+" ["+пУсловие+"] не выполнено, поэтому не добавляем рецензента"+Символы.ПС;			
			Продолжить;
		Конецесли;	
		
		Если ЗначениеЗаполнено(СтрокаОпределениеЛистаСогласования.АлгоритмНахожденияСогласователей) Тогда
			ДопПараметрыПоискаПользователя = Новый Структура();
			ДопПараметрыПоискаПользователя.Вставить("ОбъектБД",ОбъектБД);
			ДопПараметрыПоискаПользователя.Вставить("АлгоритмНахожденияСогласователей",СтрокаОпределениеЛистаСогласования.АлгоритмНахожденияСогласователей);
			Согласователь = Справочники.бпсАлгоритмыНахожденияСогласователей.ПолучитьПользователя(ДопПараметрыПоискаПользователя);
			Если Согласователь = Неопределено Тогда
				Если СтрокаОпределениеЛистаСогласования.ПропускатьЕслиНеЗаданАдресат Тогда
					ПротоколФормированияЛистаСогласования = ПротоколФормированияЛистаСогласования 
					+ "Алгоритм поиска согласователя № "
					+СтрокаОпределениеЛистаСогласования.НомерСтроки
					+" ["+СокрЛП(СтрокаОпределениеЛистаСогласования.АлгоритмНахожденияСогласователей)
					+"] не нашёл пользователя, поэтому не добавляем рецензента"+Символы.ПС;			
					Продолжить;
				Иначе
					Отказ = Истина;
					ВызватьИсключение("Алгоритм поиска согласователя № "
						+ СтрокаОпределениеЛистаСогласования.НомерСтроки
						+ " ["
						+ СокрЛП(СтрокаОпределениеЛистаСогласования.АлгоритмНахожденияСогласователей)
						+ "] не нашёл пользователя, поэтому не запускаем согласование" + Символы.ПС);
					Продолжить;
				Конецесли;	
			Конецесли;	
		Конецесли;	
			
		Если НЕ ЗначениеЗаполнено(пУсловие) Тогда
			пУсловие = "Без условия";
		Конецесли;
		СтрокаЛистСогласования = ЛистСогласования.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаЛистСогласования,СтрокаОпределениеЛистаСогласования);
		СтрокаЛистСогласования.Очередь = Очередь;
		СтрокаЛистСогласования.Пояснение = СформироватьТекстПояснения(Отказ);
		СтрокаЛистСогласования.КлючЗадачи = КлючЗадачи;
		//если подразделение устанавливается динамически, тогда меняем на подразделение из ОбъектаБД
		Если СтрокаОпределениеЛистаСогласования.Условие.ВыборПоПодразделениям Тогда
			СтрокаЛистСогласования.ПодразделениеАдресации = ОбъектБД[пУсловие.РеквизитПодразделение];
		КонецЕсли;
		
		
		Если Согласователь <> Неопределено Тогда //знаем согласователя, значит искать по роли и подразделению не будем
			СтрокаЛистСогласования.Согласователь = Согласователь;
			
			ПротоколФормированияЛистаСогласования = ПротоколФормированияЛистаСогласования 
			+ "Условие № "+СтрокаОпределениеЛистаСогласования.НомерСтроки+" ["+пУсловие+"] выполнено, поэтому "+Символы.ПС
			+ " - очередь: "+Очередь+" требуется согласование пользователя ["+СокрЛП(Согласователь)+"]"+Символы.ПС;
			
		Иначе
			ПротоколФормированияЛистаСогласования = ПротоколФормированияЛистаСогласования 
			+ "Условие № "+СтрокаОпределениеЛистаСогласования.НомерСтроки+" ["+пУсловие+"] выполнено, поэтому "+Символы.ПС
			+ " - очередь: "+Очередь+" требуется согласование с ролью ["+СтрокаЛистСогласования.РольАдресации+"]"
			+ " подразделение ["+СтрокаЛистСогласования.ПодразделениеАдресации+"]"+Символы.ПС;
		КонецЕсли;
		
		ПараметрыОтбора = Новый Структура();
		ПараметрыОтбора.Вставить("КлючСтроки",СтрокаОпределениеЛистаСогласования.КлючСтроки);
		НайденныеСтроки = ПредметСогласования.ПользователиДляУведомления.НайтиСтроки(ПараметрыОтбора);
		Для каждого СтрокаПредмет_ПользователиДляУведомления из НайденныеСтроки цикл
			СтрокаПользователиДляУведомления = ПользователиДляУведомления.Добавить();			
			ЗаполнитьЗначенияСвойств(СтрокаПользователиДляУведомления,СтрокаПредмет_ПользователиДляУведомления);
			//Если Согласователь <> Неопределено Тогда 
			//	СтрокаПользователиДляУведомления.Пользователь = Согласователь;
			//КонецЕсли;
			СтрокаПользователиДляУведомления.Очередь = Очередь;
		Конеццикла;	
		
		Если СтрокаОпределениеЛистаСогласования.НеУвеличиватьНомерОчереди = ЛОЖЬ Тогда
			Очередь = Очередь + 1;
		Конецесли;
		КлючЗадачи = КлючЗадачи + 1;
	Конеццикла;	
	
	Если ЛистСогласования.Количество() = 0 Тогда
		ПротоколФормированияЛистаСогласования = ПротоколФормированияЛистаСогласования +"
			|
			|ВНИМАНИЕ! Согласование не требуется, т.к. ни одно условий не выполнилось.";
	Конецесли;
	
	ПротоколФормированияЛистаСогласования = ПротоколФормированияЛистаСогласования + "
		|
		|
		|
		|
		|Дата формирования: "+ТекущаяДата();
	
	//Сообщить("Нет алгоритма получения ЗаполнитьЛистСогласования(Отказ)");
Конецпроцедуры

Процедура ЗаполнитьДействия(Отказ) Экспорт
	Действия.Очистить();
	Для каждого СтрокаПредметСогласованияДействия из ПредметСогласования.Действия цикл
		СтрокаДействия=Действия.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаДействия,СтрокаПредметСогласованияДействия);
	Конеццикла;
КонецПроцедуры //ЗаполнитьДействия(Отказ)

Процедура СогласоватьСРецензентомПередСозданиемЗадач(ТочкаМаршрутаБизнесПроцесса, ФормируемыеЗадачи, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры


Процедура СогласоватьСРецензентомПриСозданииЗадач(ТочкаМаршрутаБизнесПроцесса, ФормируемыеЗадачи, Отказ)
	
	ТекущийНомерОчереди = ТекущийНомерОчереди + 1;
	
	ПараметрыОтбора = Новый Структура();
	ПараметрыОтбора.Вставить("Очередь",ТекущийНомерОчереди);
	НайденныеСтроки = ЛистСогласования.НайтиСтроки(ПараметрыОтбора);
	Если НайденныеСтроки.Количество() = 0 Тогда
		ВызватьИсключение "Ошибка! Не удалось найти строку, в ТЧ: ""Лист согласования"" с номером очереди "+ТекущийНомерОчереди;
	Конецесли;
	
	ТочкиМаршрутаСогласоватьСРецензентом = БизнесПроцессы.бпсСогласование.ТочкиМаршрута.СогласоватьСРецензентом;	
	
	Для каждого СтрокаЛистСогласования из НайденныеСтроки цикл
		НаименованиеЗадачи = ПолучитьНаименованиеЗадачи();
		
		СтрокаЛистСогласования.Пояснение = СформироватьТекстПояснения(Отказ); 
		
		ЗадачаОбъект = Задачи.бпсЗадача.СоздатьЗадачу();
		ЗадачаОбъект.БизнесПроцесс = Ссылка;
		ЗадачаОбъект.ТочкаМаршрута = ТочкиМаршрутаСогласоватьСРецензентом;
		ЗадачаОбъект.Дата = ТекущаяДата();
		ЗадачаОбъект.Наименование = НаименованиеЗадачи;
		
		ЗадачаОбъект.РольАдресации = СтрокаЛистСогласования.РольАдресации;
		ЗадачаОбъект.ПодразделениеАдресации = СтрокаЛистСогласования.ПодразделениеАдресации;
		Если ЗначениеЗаполнено(СтрокаЛистСогласования.Согласователь) Тогда
			ЗадачаОбъект.Пользователь = СтрокаЛистСогласования.Согласователь;
		КонецЕсли;
		ЗадачаОбъект.КлючЗадачи = СтрокаЛистСогласования.КлючЗадачи;
		ФормируемыеЗадачи.Добавить(ЗадачаОбъект);	
		
		ЗадачаОбъект.Записать();
	Конеццикла;	
	
	Записать();
	
	Если НЕ Отказ Тогда
		Если ДополнительныеСвойства.Свойство("ЭтоСтартПроцесса") Тогда
			ОтправитьУведомление(Перечисления.бпсСобытия.ПриСтарте);	
		Конецесли;
		ОтправитьУведомление(Перечисления.бпсСобытия.ПриСозданииЗадачи);
	Конецесли;
	
	ВыполнитьДействиеПриСозданииЗадач(Отказ);
КонецПроцедуры

Процедура ВыполнитьДействиеПриСозданииЗадач(Отказ) Экспорт
	пСтатус = ПредопределенноеЗначение("Справочник.бпсСтатусыОбъектов.Согласование_ВПроцессеСогласования");
	УстановитьСтатус(пСтатус);		
КонецПроцедуры //ВыполнитьДействиеПриСозданииЗадач(Отказ)

Процедура УстановитьСтатус(Статус) Экспорт
	ДатаИзмененияСтатуса = ТекущаяДата();
	ТЗТекущиеСтатусы = ПолучитьТЗТекущиеСтатусы(ДатаИзмененияСтатуса);
	
	ТекущийСтатусОбъектаБД = ПолучитьСтатусИзТЗТекущиеСтатусы(ОбъектБД,ТЗТекущиеСтатусы);
	СтатусОбъектаБДОтличается = ТекущийСтатусОбъектаБД <> Статус;
	
	ТекущийСтатусБП = ПолучитьСтатусИзТЗТекущиеСтатусы(Ссылка,ТЗТекущиеСтатусы);
	СтатусБПОтличается = ТекущийСтатусБП <> Статус;
	Если НЕ СтатусОбъектаБДОтличается
		И НЕ СтатусБПОтличается Тогда
		Возврат;
	Конецесли;
	
	ДопПараметры = Новый Структура();
	ДопПараметры.Вставить("ДатаИзмененияСтатуса",ДатаИзмененияСтатуса);
	ДопПараметры.Вставить("ПредметСогласования",ПредметСогласования);
	ДопПараметры.Вставить("Статус",Статус);	
	ДопПараметры.Вставить("Комментарий","");
	ДопПараметры.Вставить("Основание",Ссылка);
	
	ТЗОбъектыБД = РегистрыСведений.бпсСтатусыОбъектов.ПолучитьОписаниеТЗОбъектыБД();
	
	Если СтатусОбъектаБДОтличается Тогда
		СтрокаТЗОбъектыБД = ТЗОбъектыБД.Добавить();
		СтрокаТЗОбъектыБД.ОбъектБД = ОбъектБД;
		СтрокаТЗОбъектыБД.ПредметСогласования = ПредметСогласования;
		СтрокаТЗОбъектыБД.Статус = Статус;
	Конецесли;
	Если СтатусБПОтличается Тогда
		СтрокаТЗОбъектыБД = ТЗОбъектыБД.Добавить();
		СтрокаТЗОбъектыБД.ОбъектБД = Ссылка;
		СтрокаТЗОбъектыБД.ПредметСогласования = ПредметСогласования;
		СтрокаТЗОбъектыБД.Статус = Статус;	
	Конецесли;
	ДопПараметры.Вставить("ТЗОбъектыБД",ТЗОбъектыБД);
	
	Документы.бпсРегистрацияСтатусаОбъекта.УстановитьСтатусыОбъектов(ДопПараметры);	
КонецПроцедуры //УстановитьСтатус(Статус)

Функция ПолучитьСтатусИзТЗТекущиеСтатусы(пОбъектБД,ТЗТекущиеСтатусы) Экспорт 
	пСтатус = Неопределено;
	
	ПараметрыОтбора=Новый Структура();
	ПараметрыОтбора.Вставить("ОбъектБД",пОбъектБД);
	НайденныеСтроки = ТЗТекущиеСтатусы.НайтиСтроки(ПараметрыОтбора);
	ВсегоНайденныеСтроки = НайденныеСтроки.Количество();
	Если ВсегоНайденныеСтроки = 1 тогда
		СтрокаТЗТекущиеСтатусы = НайденныеСтроки[0];	
		пСтатус = СтрокаТЗТекущиеСтатусы.Статус;
	Конецесли;
	
	Возврат пСтатус;
КонецФункции //ПолучитьСтатусИзТЗТекущиеСтатусы(пОбъектБД)

Функция ПолучитьТЗТекущиеСтатусы(ДатаИзмененияСтатуса)
	ТЗТекущиеСтатусы = Неопределено;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	бпсСтатусыОбъектовСрезПоследних.ОбъектБД,
	|	бпсСтатусыОбъектовСрезПоследних.ПредметСогласования,
	|	бпсСтатусыОбъектовСрезПоследних.Статус
	|ИЗ
	|	РегистрСведений.бпсСтатусыОбъектов.СрезПоследних(
	|			&ДатаИзмененияСтатуса,
	|			ОбъектБД В (&МассивОбъектовБД)
	|				И ПредметСогласования = &ПредметСогласования) КАК бпсСтатусыОбъектовСрезПоследних";
	
	МассивОбъектовБД = Новый Массив();
	МассивОбъектовБД.Добавить(ОбъектБД);
	МассивОбъектовБД.Добавить(Ссылка);
	Запрос.УстановитьПараметр("ДатаИзмененияСтатуса", ДатаИзмененияСтатуса);
	Запрос.УстановитьПараметр("МассивОбъектовБД", МассивОбъектовБД);
	Запрос.УстановитьПараметр("ПредметСогласования", ПредметСогласования);
	
	ТЗТекущиеСтатусы = Запрос.Выполнить().Выгрузить();
	
	Возврат ТЗТекущиеСтатусы;
КонецФункции //ПолучитьТекущиеСтатусы(ДатаИзмененияСтатуса)

Процедура ВыполнитьДействие(пДействие,Отказ) Экспорт
	ДопПараметры = Новый Структура();
	ДопПараметры.Вставить("ОбъектБД",ОбъектБД);
	
	Если пДействие = Перечисления.бпсДействия.ЗаблокироватьОбъектБД Тогда
		РегистрыСведений.бпсЗаблокированныеОбъекты.ДобавитьЗапись(ДопПараметры,Отказ);		
	ИначеЕсли пДействие = Перечисления.бпсДействия.РазблокироватьОбъектБД Тогда
		РегистрыСведений.бпсЗаблокированныеОбъекты.УдалитьЗапись(ДопПараметры,Отказ);		
	Иначе
		ВызватьИсключение "Ошибка! нет алгоритма для того чтобы выполнить действие ["+пДействие+"]";
	Конецесли;
КонецПроцедуры //ВыполнитьДействие(пДействие)

Процедура ВыполнитьДействиеПередСтартом(Отказ) Экспорт
	
	ПараметрыОтбора=Новый Структура();
	ПараметрыОтбора.Вставить("Событие",ПредопределенноеЗначение("Перечисление.бпсСобытия.ПередСтартом"));
	НайденныеСтроки = Действия.НайтиСтроки(ПараметрыОтбора);
	Для каждого СтрокаДействия из НайденныеСтроки цикл
		ВыполнитьДействие(СтрокаДействия.Действие,Отказ);
	Конеццикла;
	
КонецПроцедуры 

Функция ПолучитьНаименованиеЗадачи(ТочкаМаршрута = Неопределено) Экспорт 	
	Если ТочкаМаршрута = БизнесПроцессы.бпсСогласование.ТочкиМаршрута.ОбработатьРезультатыСогласования Тогда
		НаименованиеЗадачи = "Необходимо исправить: ["+ОбъектБД+"]";
	Иначе
		НаименованиеЗадачи = "Согласуйте: ["+ОбъектБД +"]";	
	КонецЕсли;
	
	Возврат НаименованиеЗадачи;	
КонецФункции //ПолучитьНаименованиеЗадачи()


Процедура СогласоватьСРецензентомПриВыполнении(ТочкаМаршрутаБизнесПроцесса, Задача, Отказ)
	Если НЕ Отказ Тогда
		ОтправитьУведомление(Перечисления.бпсСобытия.ПриВыполненииЗадачиВОчереди);
	Конецесли;
КонецПроцедуры


Процедура УсловиеСогласованоСРецензентомПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	ПараметрыОтбора=Новый Структура();
	ПараметрыОтбора.Вставить("Очередь",ТекущийНомерОчереди);
	НайденныеСтроки = ЛистСогласования.НайтиСтроки(ПараметрыОтбора);
	Результат = Истина;
	Для каждого СтрокаЛистСогласования из НайденныеСтроки цикл
		Если НЕ СтрокаЛистСогласования.Согласовано Тогда
			Результат = Ложь;
		Конецесли;
	Конеццикла;	
КонецПроцедуры


Процедура УсловиеЕщеЕстьРецензентыПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	ПараметрыОтбора=Новый Структура();
	ПараметрыОтбора.Вставить("Очередь",ТекущийНомерОчереди + 1);
	НайденныеСтроки = ЛистСогласования.НайтиСтроки(ПараметрыОтбора);
	Результат = НайденныеСтроки.Количество() > 0;
КонецПроцедуры


Процедура УсловиеОбработатьРеценезииПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	Если НЕ РазрешеноПовторноеСогласование Тогда
		Результат = Ложь;
	Иначе
		Если ОтправитьНаПовторноеСогласование Тогда
			Результат = Истина;
		Иначе
			Результат = Ложь;
		Конецесли;
		//ПараметрыОтбора=Новый Структура();
		//ПараметрыОтбора.Вставить("Очередь",ТекущийНомерОчереди);
		//НайденныеСтроки = ЛистСогласования.НайтиСтроки(ПараметрыОтбора);
		//Для каждого СтрокаЛистСогласования из НайденныеСтроки цикл
		//	Если НЕ СтрокаЛистСогласования.ВозвращеноНаДоработку Тогда
		//		Результат = Ложь;
		//	Конецесли;
		//Конеццикла;	
	Конецесли;
КонецПроцедуры


Процедура ОбработатьРезультатыСогласованияПриСозданииЗадач(ТочкаМаршрутаБизнесПроцесса, ФормируемыеЗадачи, Отказ)
	Для каждого СтрокаФормируемыеЗадачи из ФормируемыеЗадачи цикл
		СтрокаФормируемыеЗадачи.Наименование = ПолучитьНаименованиеЗадачи(ТочкаМаршрутаБизнесПроцесса);
		СтрокаФормируемыеЗадачи.Пользователь = Инициатор;		
	Конеццикла;
	Если Отказ Тогда
		Возврат;
	Конецесли;
	ВыполнитьДействиПриВозвращенииНаДоработку(Отказ);
КонецПроцедуры

Процедура ВыполнитьДействиПриВозвращенииНаДоработку(Отказ) Экспорт	
	пСтатус = ПредопределенноеЗначение("Справочник.бпсСтатусыОбъектов.Согласование_ВозвращеноНаДоработку");
	
	ПараметрыОтбора=Новый Структура();
	ПараметрыОтбора.Вставить("Событие",ПредопределенноеЗначение("Перечисление.бпсСобытия.ПриВозвращенииНаДоработку"));
	НайденныеСтроки = Действия.НайтиСтроки(ПараметрыОтбора);
	Для каждого СтрокаДействия из НайденныеСтроки цикл
		ВыполнитьДействие(СтрокаДействия.Действие,Отказ);
	Конеццикла;	
	УстановитьСтатус(пСтатус);	
КонецПроцедуры //ВыполнитьДействиПриВозвращенииНаДоработку(Отказ)


Процедура УсловиеСогласоватьПовторноПроверкаУсловия(ТочкаМаршрутаБизнесПроцесса, Результат)
	Результат = ОтправитьНаПовторноеСогласование;
	Если Результат Тогда
		Отказ = Ложь;
		ПараметрыОтбора=Новый Структура();
		ПараметрыОтбора.Вставить("Событие",ПредопределенноеЗначение("Перечисление.бпсСобытия.ПередСтартом"));
		НайденныеСтроки = Действия.НайтиСтроки(ПараметрыОтбора);
		Для каждого СтрокаДействия из НайденныеСтроки цикл
			ВыполнитьДействие(СтрокаДействия.Действие,Отказ);
		Конеццикла;
		Если Отказ Тогда
			ВызватьИсключение "Ошибка! Не удалось выполнить действие";
		Конецесли;
		
		ПараметрыОтбора=Новый Структура();
		ПараметрыОтбора.Вставить("Очередь",ТекущийНомерОчереди);
		НайденныеСтроки = ЛистСогласования.НайтиСтроки(ПараметрыОтбора);
		Для каждого СтрокаЛистСогласования из НайденныеСтроки цикл
			СтрокаЛистСогласования.Согласовано = Ложь;
			СтрокаЛистСогласования.Рецензия = "";
		Конеццикла;	
		Если ТекущийНомерОчереди > 0 Тогда
			ТекущийНомерОчереди = ТекущийНомерОчереди - 1;
		Конецесли;	
		ОтправитьНаПовторноеСогласование = Ложь;
		Записать()
	Конецесли;
КонецПроцедуры


Процедура ЗавершениеПриЗавершении(ТочкаМаршрутаБизнесПроцесса, Отказ)
	Согласовано = Истина;
	Для каждого СтрокаЛистСогласования из ЛистСогласования цикл
		Если НЕ СтрокаЛистСогласования.Согласовано Тогда
			Согласовано = Ложь;	
		Конецесли;
	Конеццикла;
	Если НЕ Отказ Тогда
		ОтправитьУведомление(ПредопределенноеЗначение("Перечисление.бпсСобытия.ПриЗавершении"));
	Конецесли;	
	ВыполнитьДействиеПриЗавершении(Отказ);
КонецПроцедуры

Процедура ВыполнитьДействиеПриЗавершении(Отказ) Экспорт
	
	МассивСобытийЗавершения = Новый Массив();
	МассивСобытийЗавершения.Добавить(ПредопределенноеЗначение("Перечисление.бпсСобытия.ПриЗавершении"));
	Если Согласовано Тогда
		МассивСобытийЗавершения.Добавить(ПредопределенноеЗначение("Перечисление.бпсСобытия.ПриЗавершенииЕслиСогласовано"));
	Иначе
		МассивСобытийЗавершения.Добавить(ПредопределенноеЗначение("Перечисление.бпсСобытия.ПриЗавершенииЕслиНеСогласовано"));
	Конецесли;
	          	
	ЕстьДействиеРазблокироватьОбъект = Ложь;
	Для каждого ЭлМассиваСобытийЗавершения из МассивСобытийЗавершения цикл
		ПараметрыОтбора=Новый Структура();
		ПараметрыОтбора.Вставить("Событие",ЭлМассиваСобытийЗавершения);
		НайденныеСтроки = Действия.НайтиСтроки(ПараметрыОтбора);
		Для каждого СтрокаДействия из НайденныеСтроки цикл
			ВыполнитьДействие(СтрокаДействия.Действие,Отказ);
		Конеццикла;			
	Конеццикла;
	
	Если Согласовано Тогда
		пСтатус = ПредопределенноеЗначение("Справочник.бпсСтатусыОбъектов.Согласование_Утверждено");
	Иначе
		пСтатус = ПредопределенноеЗначение("Справочник.бпсСтатусыОбъектов.Согласование_Отклонено");
	Конецесли;	
	УстановитьСтатус(пСтатус);		
КонецПроцедуры //ВыполнитьДействиеПриЗавершении(Отказ)

Процедура ВыполнитьЗадачу(ДопПараметры) Экспорт
	Отказ = Ложь;
	
	ЗадачаСсылка = ДопПараметры.ЗадачаСсылка;
	КомандаСогласования = ДопПараметры.КомандаСогласования;
	ЭтоКомандаСогласования_Согласовано = КомандаСогласования = ПредопределенноеЗначение("Перечисление.бпсКомандыСогласования.Согласовано");
	ЭтоКомандаСогласования_НеСогласовано = КомандаСогласования = ПредопределенноеЗначение("Перечисление.бпсКомандыСогласования.НеСогласовано");
	ЭтоКомандаСогласования_ВернутьНаДоработку = КомандаСогласования = ПредопределенноеЗначение("Перечисление.бпсКомандыСогласования.ВернутьНаДоработку");
	ЭтоКомандаСогласования_ОтправитьНаПовторноеСогласование = КомандаСогласования = ПредопределенноеЗначение("Перечисление.бпсКомандыСогласования.ОтправитьНаПовторноеСогласование");
	ЭтоКомандаСогласования_ПрекратитьСогласование = КомандаСогласования = ПредопределенноеЗначение("Перечисление.бпсКомандыСогласования.ПрекратитьСогласование");
	
	пСогласовано = Ложь;
	Если ЭтоКомандаСогласования_Согласовано Тогда
		пСогласовано = Истина;
	ИначеЕсли ЭтоКомандаСогласования_НеСогласовано
		ИЛИ ЭтоКомандаСогласования_ВернутьНаДоработку Тогда
		пСогласовано = Ложь;
	ИначеЕсли ЭтоКомандаСогласования_ОтправитьНаПовторноеСогласование
		ИЛИ ЭтоКомандаСогласования_ПрекратитьСогласование Тогда
	Иначе
		ВызватьИсключение "Ошибка! нет алгоритма выполнения задачи для команды ["+КомандаСогласования+"]";
	Конецесли;
	
	ОтправитьНаПовторноеСогласование = Ложь;
	Если ЭтоКомандаСогласования_ВернутьНаДоработку
		ИЛИ ЭтоКомандаСогласования_ОтправитьНаПовторноеСогласование Тогда
		ОтправитьНаПовторноеСогласование = Истина;
	Конецесли;
	
	пКлючЗадачи = ЗадачаСсылка.КлючЗадачи;
	
	ПараметрыОтбора=Новый Структура();
	ПараметрыОтбора.Вставить("КлючЗадачи",пКлючЗадачи);
	
	НайденныеСтроки = ЛистСогласования.НайтиСтроки(ПараметрыОтбора);
	Более1ЗаписиНайдено = НайденныеСтроки.Количество()>1;
	Для каждого СтрокаЛистСогласования из НайденныеСтроки цикл
		СтрокаЛистСогласования.Рецензия = ДопПараметры.Рецензия;
		СтрокаЛистСогласования.Согласовано = пСогласовано;				
	Конеццикла;	
	Записать();	
	
	Если ЭтоКомандаСогласования_Согласовано 
		ИЛИ ЭтоКомандаСогласования_НеСогласовано
		ИЛИ ЭтоКомандаСогласования_ВернутьНаДоработку Тогда
		
		пЗадачаОбъект = ЗадачаСсылка.ПолучитьОбъект();
		
		ДопПараметрыРС = Новый Структура();
		ДопПараметрыРС.Вставить("ЗадачаСсылка",ДопПараметры.ЗадачаСсылка);
		ДопПараметрыРС.Вставить("Рецензия",ДопПараметры.Рецензия);
		ДопПараметрыРС.Вставить("Согласовано",пСогласовано);
		ДопПараметрыРС.Вставить("Очередь",ТекущийНомерОчереди);
		
		//ВозвращенаНаДоработку = Ложь;
		//Если ЭтоКомандаСогласования_ВернутьНаДоработку Тогда
		//	пЗадачаОбъект.ВозвращенаНаДоработку = Истина;
		//	ДопПараметрыРС.Вставить("ВозвращенаНаДоработку",Истина);		
		//Конецесли;
		
		СформироватьЗаписиРС_бпсЗадачиПоБизнесПроцессам(ДопПараметрыРС,Отказ);
		Если Отказ Тогда
			ВызватьИсключение "Ошибка! не удалось выполнить задачу";
		Конецесли;
		пЗадачаОбъект.ВыполнитьЗадачу();	
		
	ИначеЕсли ЭтоКомандаСогласования_ОтправитьНаПовторноеСогласование
		ИЛИ ЭтоКомандаСогласования_ПрекратитьСогласование Тогда
		ЗадачаОбъект = ЗадачаСсылка.ПолучитьОбъект(); 
		ЗадачаОбъект.ВыполнитьЗадачу();					
	Конецесли;
КонецПроцедуры //ВыполнитьЗадачу

Процедура СформироватьЗаписиРС_бпсЗадачиПоБизнесПроцессам(ДопПараметрыРС,Отказ) Экспорт	
	Если Отказ Тогда
		Возврат;
	Конецесли;
	НаборЗаписей = РегистрыСведений.бпсЗадачиПоБизнесПроцессам.СоздатьНаборЗаписей();
	НаборЗаписей.СформироватьЗаписи(ДопПараметрыРС,Отказ);
КонецПроцедуры 

Процедура ПриЗаписи(Отказ)
	Если ДополнительныеСвойства.Свойство("ЭтоНовый")
		И ДополнительныеСвойства.ЭтоНовый Тогда
		РегистрыСведений.бпсБизнесПроцессыСогласования.ДобавитьЗапись(Ссылка,Отказ);
		ДополнительныеСвойства.Удалить("ЭтоНовый");
	Конецесли;
КонецПроцедуры


Процедура ПередЗаписью(Отказ)
	ДополнительныеСвойства.Вставить("ЭтоНовый",ЭтоНовый());
КонецПроцедуры

