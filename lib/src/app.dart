import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../browser_adapter.dart' as browser;

const String _brandName = 'LatteConect';
const String _brandCaption = 'banco de leite';
const String _eventsStorageKey = 'latteconect-operational-events';
const String _notificationsStorageKey = 'latteconect-notifications';
const double _maxContentWidth = 1420;
const double _headerHeight = 78;
const double _radius = 8;

class AppColors {
  static const Color background = Color(0xFFFBF7F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF6FBFF);
  static const Color surfaceWarm = Color(0xFFFFF7EA);
  static const Color ink = Color(0xFF061A3D);
  static const Color muted = Color(0xFF50627F);
  static const Color line = Color(0xFFD9E5F2);
  static const Color lineWarm = Color(0xFFEFD8BD);
  static const Color blue = Color(0xFF004F9F);
  static const Color blueDark = Color(0xFF00346F);
  static const Color blueSoft = Color(0xFFE7F4FF);
  static const Color sky = Color(0xFF67B7E8);
  static const Color gold = Color(0xFFD68A05);
  static const Color goldSoft = Color(0xFFFFF4DF);
  static const Color green = Color(0xFF42A86B);
  static const Color greenSoft = Color(0xFFE9F6EE);
}

class AppText {
  static const TextStyle body = TextStyle(
    color: AppColors.ink,
    fontFamily: 'Arial',
    height: 1.45,
  );

  static TextStyle eyebrow() => const TextStyle(
    color: AppColors.gold,
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.15,
  );

  static TextStyle title(double size) => TextStyle(
    color: AppColors.blueDark,
    fontFamily: 'Georgia',
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: 1.06,
    letterSpacing: 0,
  );

  static TextStyle sectionTitle([double size = 35]) => TextStyle(
    color: AppColors.blueDark,
    fontFamily: 'Georgia',
    fontSize: size,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: 0,
  );

  static const TextStyle lead = TextStyle(
    color: AppColors.muted,
    fontSize: 17,
    height: 1.7,
    letterSpacing: 0,
  );

  static const TextStyle paragraph = TextStyle(
    color: AppColors.muted,
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0,
  );

  static const TextStyle label = TextStyle(
    color: AppColors.blueDark,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );
}

BoxDecoration _panelDecoration({
  Color color = const Color(0xE6FFFFFF),
  Color borderColor = AppColors.lineWarm,
  Gradient? gradient,
}) {
  return BoxDecoration(
    color: gradient == null ? color : null,
    gradient: gradient,
    border: Border.all(color: borderColor),
    borderRadius: BorderRadius.circular(_radius),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1C0E2B52),
        blurRadius: 50,
        offset: Offset(0, 18),
      ),
    ],
  );
}

enum EventKind {
  cadastro('Cadastro'),
  coleta('Coleta'),
  pedido('Pedido'),
  hospital('Hospital');

  const EventKind(this.label);
  final String label;

  static EventKind fromLabel(String label) {
    return EventKind.values.firstWhere(
      (kind) => kind.label == label,
      orElse: () => EventKind.cadastro,
    );
  }
}

class OperationalEvent {
  const OperationalEvent({
    required this.id,
    required this.kind,
    required this.title,
    required this.subject,
    required this.contact,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    required this.statusTone,
    required this.createdAt,
  });

  final String id;
  final EventKind kind;
  final String title;
  final String subject;
  final String contact;
  final String location;
  final String date;
  final String time;
  final String status;
  final String statusTone;
  final String createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.label,
    'title': title,
    'subject': subject,
    'contact': contact,
    'location': location,
    'date': date,
    'time': time,
    'status': status,
    'statusTone': statusTone,
    'createdAt': createdAt,
  };

  static OperationalEvent? fromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      return null;
    }

    String read(String key, String fallback) {
      final raw = value[key];
      return raw is String && raw.trim().isNotEmpty ? raw : fallback;
    }

    return OperationalEvent(
      id: read('id', 'stored-${DateTime.now().microsecondsSinceEpoch}'),
      kind: EventKind.fromLabel(read('kind', 'Cadastro')),
      title: read('title', 'Movimentacao registrada'),
      subject: read('subject', 'Sem nome'),
      contact: read('contact', 'Sem contato'),
      location: read('location', 'Sem local'),
      date: read('date', 'Sem data'),
      time: read('time', 'Sem horario'),
      status: read('status', 'Recebido'),
      statusTone: read('statusTone', 'blue'),
      createdAt: read('createdAt', formatCreatedAt()),
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String createdAt;

  Map<String, String> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'createdAt': createdAt,
  };

  static AppNotification? fromJson(Object? value) {
    if (value is! Map<String, Object?>) return null;
    final title = value['title'];
    final message = value['message'];
    if (title is! String || message is! String) return null;
    return AppNotification(
      id:
          value['id'] as String? ??
          'notice-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: value['createdAt'] as String? ?? formatCreatedAt(),
    );
  }
}

class ScheduleDraft {
  const ScheduleDraft({
    required this.nome,
    required this.telefone,
    required this.cep,
    required this.data,
    required this.horario,
    required this.hospital,
  });

  final String nome;
  final String telefone;
  final String cep;
  final String data;
  final String horario;
  final String hospital;
}

class ActionCardData {
  const ActionCardData({
    required this.title,
    required this.description,
    required this.path,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String description;
  final String path;
  final IconData icon;
  final String tone;
}

class Hospital {
  const Hospital({
    required this.name,
    required this.district,
    required this.distance,
    required this.stock,
    required this.address,
    required this.x,
    required this.y,
    required this.intensity,
  });

  final String name;
  final String district;
  final String distance;
  final String stock;
  final String address;
  final double x;
  final double y;
  final int intensity;
}

class CalendarDay {
  const CalendarDay({
    required this.label,
    required this.iso,
    this.muted = false,
  });

  final String label;
  final String iso;
  final bool muted;
}

const Map<String, String> _defaultDonor = {
  'nome': 'Marina Santos',
  'telefone': '(11) 98888-2211',
  'email': 'marina.santos@email.com',
  'nascimento': '1996-03-12',
  'estadoCivil': 'Casada',
  'cep': '04039-000',
  'bairro': 'Vila Clementino',
  'endereco': 'Rua Botucatu, 740 - apto 52',
  'parto': '2026-03-18',
  'medicamentos': 'Nao',
};

const ScheduleDraft _defaultSchedule = ScheduleDraft(
  nome: 'Marina Santos',
  telefone: '(11) 98888-2211',
  cep: '04039-000',
  data: '2026-05-28',
  horario: '09:00 - 10:00',
  hospital: 'Hospital Sao Paulo',
);

const Map<String, String> _defaultRequest = {
  'solicitante': 'Renata Alves',
  'telefone': '(11) 97777-1122',
  'perfil': 'Familia',
  'email': 'renata.alves@email.com',
  'paciente': 'Livia Alves',
  'urgencia': 'Alta - UTI neonatal',
};

const Map<String, String> _defaultLogin = {
  'email': 'gestor@latteconect.org.br',
  'senha': 'latteconect123',
  'perfil': 'Banco de leite',
};

const List<String> _monthNames = [
  'janeiro',
  'fevereiro',
  'marco',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];

const List<OperationalEvent> _seedOperationalEvents = [
  OperationalEvent(
    id: 'seed-schedule',
    kind: EventKind.coleta,
    title: 'Coleta agendada',
    subject: 'Ana Souza',
    contact: '(11) 98888-1020',
    location: 'Vila Clementino',
    date: '28 de maio de 2026',
    time: '09:00 - 10:00',
    status: 'Confirmado',
    statusTone: 'green',
    createdAt: '25/05/2026 - 09:42',
  ),
  OperationalEvent(
    id: 'seed-request',
    kind: EventKind.pedido,
    title: 'Pedido de leite enviado',
    subject: 'Hospital Materno Luz',
    contact: '(11) 3777-2200',
    location: 'Mooca',
    date: '26 de maio de 2026',
    time: 'Prioridade alta',
    status: 'Em triagem',
    statusTone: 'blue',
    createdAt: '25/05/2026 - 11:16',
  ),
  OperationalEvent(
    id: 'seed-registration',
    kind: EventKind.cadastro,
    title: 'Cadastro de nutriz',
    subject: 'Julia Lima',
    contact: '(11) 96666-3344',
    location: 'Mooca',
    date: '25 de maio de 2026',
    time: 'Cadastro recebido',
    status: 'Em analise',
    statusTone: 'blue',
    createdAt: '25/05/2026 - 14:05',
  ),
];

const List<ActionCardData> _actionCards = [
  ActionCardData(
    title: 'Quero doar leite',
    description: 'Cadastro guiado e agendamento de coleta domiciliar.',
    path: '/doar',
    icon: Icons.water_drop_outlined,
    tone: 'blue',
  ),
  ActionCardData(
    title: 'Preciso de doacao',
    description: 'Solicitacao para familias, hospitais e bancos parceiros.',
    path: '/solicitar',
    icon: Icons.local_drink_outlined,
    tone: 'gold',
  ),
  ActionCardData(
    title: 'Encontrar hospital',
    description: 'Consulta de unidades parceiras por bairro e CEP.',
    path: '/hospitais',
    icon: Icons.local_hospital_outlined,
    tone: 'blue-soft',
  ),
  ActionCardData(
    title: 'Ver impacto',
    description: 'Entenda como cada doacao ajuda bebes e familias.',
    path: '/impacto',
    icon: Icons.favorite_border,
    tone: 'blue-soft',
  ),
  ActionCardData(
    title: 'Orientacao e apoio',
    description: 'Tire duvidas e encontre caminhos, mesmo sem querer doar.',
    path: '/orientacao',
    icon: Icons.forum_outlined,
    tone: 'gold',
  ),
];

const List<(String, String, String)> _processSteps = [
  ('1', 'Cadastro', 'A nutriz registra dados basicos e contato.'),
  ('2', 'Agendamento', 'A coleta domiciliar e marcada com a unidade parceira.'),
  (
    '3',
    'Triagem',
    'O leite passa por analise, preparo e armazenamento seguro.',
  ),
  ('4', 'Distribuicao', 'Hospitais direcionam o leite aos bebes que precisam.'),
];

const List<(String, String, String)> _formSteps = [
  ('1', 'Dados pessoais', 'Informacoes basicas'),
  ('2', 'Endereco para coleta', 'Local de retirada'),
  ('3', 'Informacoes de saude', 'Triagem inicial'),
  ('4', 'Consentimento', 'Termos e autorizacoes'),
];

const List<CalendarDay> _calendarDays = [
  CalendarDay(label: '26', iso: '2026-04-26', muted: true),
  CalendarDay(label: '27', iso: '2026-04-27', muted: true),
  CalendarDay(label: '28', iso: '2026-04-28', muted: true),
  CalendarDay(label: '29', iso: '2026-04-29', muted: true),
  CalendarDay(label: '30', iso: '2026-04-30', muted: true),
  CalendarDay(label: '1', iso: '2026-05-01'),
  CalendarDay(label: '2', iso: '2026-05-02'),
  CalendarDay(label: '3', iso: '2026-05-03'),
  CalendarDay(label: '4', iso: '2026-05-04'),
  CalendarDay(label: '5', iso: '2026-05-05'),
  CalendarDay(label: '6', iso: '2026-05-06'),
  CalendarDay(label: '7', iso: '2026-05-07'),
  CalendarDay(label: '8', iso: '2026-05-08'),
  CalendarDay(label: '9', iso: '2026-05-09'),
  CalendarDay(label: '10', iso: '2026-05-10'),
  CalendarDay(label: '11', iso: '2026-05-11'),
  CalendarDay(label: '12', iso: '2026-05-12'),
  CalendarDay(label: '13', iso: '2026-05-13'),
  CalendarDay(label: '14', iso: '2026-05-14'),
  CalendarDay(label: '15', iso: '2026-05-15'),
  CalendarDay(label: '16', iso: '2026-05-16'),
  CalendarDay(label: '17', iso: '2026-05-17'),
  CalendarDay(label: '18', iso: '2026-05-18'),
  CalendarDay(label: '19', iso: '2026-05-19'),
  CalendarDay(label: '20', iso: '2026-05-20'),
  CalendarDay(label: '21', iso: '2026-05-21'),
  CalendarDay(label: '22', iso: '2026-05-22'),
  CalendarDay(label: '23', iso: '2026-05-23'),
  CalendarDay(label: '24', iso: '2026-05-24'),
  CalendarDay(label: '25', iso: '2026-05-25'),
  CalendarDay(label: '26', iso: '2026-05-26'),
  CalendarDay(label: '27', iso: '2026-05-27'),
  CalendarDay(label: '28', iso: '2026-05-28'),
  CalendarDay(label: '29', iso: '2026-05-29'),
  CalendarDay(label: '30', iso: '2026-05-30'),
  CalendarDay(label: '31', iso: '2026-05-31'),
  CalendarDay(label: '1', iso: '2026-06-01', muted: true),
  CalendarDay(label: '2', iso: '2026-06-02', muted: true),
  CalendarDay(label: '3', iso: '2026-06-03', muted: true),
  CalendarDay(label: '4', iso: '2026-06-04', muted: true),
  CalendarDay(label: '5', iso: '2026-06-05', muted: true),
  CalendarDay(label: '6', iso: '2026-06-06', muted: true),
];

const List<String> _timeSlots = [
  '08:00 - 09:00',
  '09:00 - 10:00',
  '10:00 - 11:00',
  '13:00 - 14:00',
  '14:00 - 15:00',
  '16:00 - 17:00',
];

const List<Hospital> _hospitals = [
  Hospital(
    name: 'Hospital Sao Paulo',
    district: 'Vila Clementino',
    distance: '1,1 km',
    stock: '52 L',
    address: 'Rua Napoleao de Barros, 715',
    x: 55,
    y: 62,
    intensity: 5,
  ),
  Hospital(
    name: 'Hospital Sepaco',
    district: 'Vila Mariana',
    distance: '1,4 km',
    stock: '45 L',
    address: 'Rua Vergueiro, 4210',
    x: 63,
    y: 34,
    intensity: 4,
  ),
  Hospital(
    name: 'Hospital Japones Santa Cruz',
    district: 'Vila Mariana',
    distance: '1,9 km',
    stock: '38 L',
    address: 'Rua Santa Cruz, 398',
    x: 30,
    y: 28,
    intensity: 4,
  ),
  Hospital(
    name: 'Instituto Dante Pazzanese',
    district: 'Vila Mariana',
    distance: '2,0 km',
    stock: '24 L',
    address: 'Av. Dr. Dante Pazzanese, 500',
    x: 42,
    y: 76,
    intensity: 3,
  ),
  Hospital(
    name: 'Hospital Paulista',
    district: 'Vila Clementino',
    distance: '1,0 km',
    stock: '31 L',
    address: 'Rua Dr. Diogo de Faria, 780',
    x: 48,
    y: 48,
    intensity: 3,
  ),
];

const List<(String, String, String)> _impactStats = [
  (
    '3',
    'bebes alimentados',
    'Uma doacao pode apoiar ate tres bebes em atendimento neonatal.',
  ),
  (
    '45 L',
    'em estoque',
    'Volume monitorado pela rede parceira para evitar ruptura.',
  ),
  (
    '24 h',
    'para retorno',
    'A equipe parceira entra em contato apos cadastro ou solicitacao.',
  ),
  (
    '217',
    'unidades parceiras',
    'Hospitais e bancos conectados para aproximar doacao e demanda.',
  ),
];

String formatLongDate(String isoDate) {
  final parts = isoDate.split('-').map(int.tryParse).toList();
  if (parts.length != 3 ||
      parts[0] == null ||
      parts[1] == null ||
      parts[2] == null ||
      parts[1]! < 1 ||
      parts[1]! > 12) {
    return isoDate;
  }

  return '${parts[2]} de ${_monthNames[parts[1]! - 1]} de ${parts[0]}';
}

String formatCreatedAt([DateTime? date]) {
  final current = date ?? DateTime.now();
  String two(int value) => value.toString().padLeft(2, '0');

  return '${two(current.day)}/${two(current.month)}/${current.year} - ${two(current.hour)}:${two(current.minute)}';
}

OperationalEvent createOperationalEvent(
  EventKind kind, {
  required String title,
  required String subject,
  required String contact,
  required String location,
  required String date,
  required String time,
  required String status,
  required String statusTone,
}) {
  final now = DateTime.now();
  return OperationalEvent(
    id: '${kind.label.toLowerCase()}-${now.microsecondsSinceEpoch}',
    kind: kind,
    title: title,
    subject: subject,
    contact: contact,
    location: location,
    date: date,
    time: time,
    status: status,
    statusTone: statusTone,
    createdAt: formatCreatedAt(now),
  );
}

List<OperationalEvent> getStoredOperationalEvents() {
  try {
    final raw = browser.readLocalStorage(_eventsStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) {
      return [];
    }
    return decoded
        .map(OperationalEvent.fromJson)
        .whereType<OperationalEvent>()
        .toList();
  } catch (_) {
    return [];
  }
}

List<OperationalEvent> getOperationalEvents() {
  return [
    ...getStoredOperationalEvents(),
    ..._seedOperationalEvents,
  ].take(12).toList();
}

List<AppNotification> getStoredNotifications() {
  try {
    final raw = browser.readLocalStorage(_notificationsStorageKey);
    if (raw == null || raw.trim().isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) return [];
    return decoded
        .map(AppNotification.fromJson)
        .whereType<AppNotification>()
        .toList();
  } catch (_) {
    return [];
  }
}

List<AppNotification> getNotifications() => [
  ...getStoredNotifications(),
  const AppNotification(
    id: 'welcome',
    title: 'Bem-vinda ao LatteConect',
    message: 'Conheca orientacoes, hospitais parceiros e formas de doar.',
    createdAt: 'Agora',
  ),
];

void saveNotification(String title, String message) {
  final notification = AppNotification(
    id: 'notice-${DateTime.now().microsecondsSinceEpoch}',
    title: title,
    message: message,
    createdAt: formatCreatedAt(),
  );
  final updated = [notification, ...getStoredNotifications()].take(12).toList();
  browser.writeLocalStorage(
    _notificationsStorageKey,
    jsonEncode(updated.map((item) => item.toJson()).toList()),
  );
}

String createProtocol(String prefix) {
  final now = DateTime.now();
  final suffix = (now.microsecondsSinceEpoch % 10000).toString().padLeft(
    4,
    '0',
  );
  return 'LTC-$prefix-${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$suffix';
}

void saveOperationalEvent(OperationalEvent event) {
  final updatedEvents = [
    event,
    ...getStoredOperationalEvents(),
  ].take(20).toList();
  browser.writeLocalStorage(
    _eventsStorageKey,
    jsonEncode(updatedEvents.map((event) => event.toJson()).toList()),
  );
}

enum LattePage {
  home,
  howItWorks,
  donate,
  schedule,
  donorConfirmed,
  scheduleConfirmed,
  donationMode,
  hospitalDelivery,
  request,
  requestConfirmed,
  hospitals,
  impact,
  guidance,
  journey,
  login,
  dashboard,
}

class LatteRoute {
  const LatteRoute(this.page, this.query);

  final LattePage page;
  final Map<String, String> query;

  static LatteRoute fromLocation(String location) {
    final uri = Uri.tryParse(location) ?? Uri(path: '/');
    final path = uri.path.isEmpty ? '/' : uri.path;
    final page = switch (path) {
      '/' => LattePage.home,
      '/como-funciona' => LattePage.howItWorks,
      '/doar' => LattePage.donate,
      '/doar/agendamento' => LattePage.schedule,
      '/doar/confirmado' => LattePage.donorConfirmed,
      '/doar/agendamento-confirmado' => LattePage.scheduleConfirmed,
      '/doar/modalidade' => LattePage.donationMode,
      '/doar/entrega-hospital' => LattePage.hospitalDelivery,
      '/solicitar' => LattePage.request,
      '/solicitar/confirmado' => LattePage.requestConfirmed,
      '/hospitais' => LattePage.hospitals,
      '/impacto' => LattePage.impact,
      '/orientacao' => LattePage.guidance,
      '/minha-jornada' => LattePage.journey,
      '/entrar' => LattePage.login,
      '/painel' => LattePage.dashboard,
      _ => LattePage.home,
    };

    return LatteRoute(page, uri.queryParameters);
  }
}

String _titleForPage(LattePage page) {
  return switch (page) {
    LattePage.home => '$_brandName | Banco de leite digital',
    LattePage.howItWorks => 'Como funciona | $_brandName',
    LattePage.donate => 'Quero doar leite | $_brandName',
    LattePage.schedule => 'Agendar coleta | $_brandName',
    LattePage.donorConfirmed => 'Cadastro confirmado | $_brandName',
    LattePage.scheduleConfirmed => 'Agendamento confirmado | $_brandName',
    LattePage.donationMode => 'Como doar | $_brandName',
    LattePage.hospitalDelivery => 'Entrega no hospital | $_brandName',
    LattePage.request => 'Preciso de doacao | $_brandName',
    LattePage.requestConfirmed => 'Solicitacao enviada | $_brandName',
    LattePage.hospitals => 'Hospitais parceiros | $_brandName',
    LattePage.impact => 'Impacto da doacao | $_brandName',
    LattePage.guidance => 'Orientacao e apoio | $_brandName',
    LattePage.journey => 'Minha jornada | $_brandName',
    LattePage.login => 'Entrar | $_brandName',
    LattePage.dashboard => 'Painel gestor | $_brandName',
  };
}

String _urlForPath(String path, [Map<String, String>? query]) {
  final cleanedQuery = <String, String>{};
  query?.forEach((key, value) {
    if (value.trim().isNotEmpty) {
      cleanedQuery[key] = value.trim();
    }
  });

  return Uri(
    path: path,
    queryParameters: cleanedQuery.isEmpty ? null : cleanedQuery,
  ).toString();
}

typedef NavigateTo = void Function(String path, {Map<String, String>? query});
typedef RecordEvent = void Function(OperationalEvent event);

class LatteConectApp extends StatelessWidget {
  const LatteConectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '$_brandName | Banco de leite digital',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        fontFamily: 'Arial',
        scaffoldBackgroundColor: AppColors.background,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.blueDark,
          fontFamily: 'Arial',
        ),
        useMaterial3: true,
      ),
      home: const _LatteRouter(),
    );
  }
}

class _LatteRouter extends StatefulWidget {
  const _LatteRouter();

  @override
  State<_LatteRouter> createState() => _LatteRouterState();
}

class _LatteRouterState extends State<_LatteRouter> {
  late LatteRoute _route;
  StreamSubscription<void>? _popStateSubscription;

  @override
  void initState() {
    super.initState();
    _route = LatteRoute.fromLocation(browser.currentLocation());
    browser.setDocumentTitle(_titleForPage(_route.page));
    _popStateSubscription = browser.onPopState.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _route = LatteRoute.fromLocation(browser.currentLocation());
      });
      browser.setDocumentTitle(_titleForPage(_route.page));
    });
  }

  @override
  void dispose() {
    _popStateSubscription?.cancel();
    super.dispose();
  }

  void _navigate(String path, {Map<String, String>? query}) {
    final url = _urlForPath(path, query);
    browser.pushUrl(url);
    setState(() {
      _route = LatteRoute.fromLocation(url);
    });
    browser.setDocumentTitle(_titleForPage(_route.page));
  }

  void _recordEvent(OperationalEvent event) {
    saveOperationalEvent(event);
    final message = switch (event.kind) {
      EventKind.cadastro =>
        'Cadastro recebido. A equipe fara a triagem inicial em ate 24 horas uteis.',
      EventKind.coleta =>
        'Agendamento confirmado. Guarde o protocolo para acompanhar sua jornada.',
      EventKind.pedido => 'Solicitacao enviada para a rede parceira.',
      EventKind.hospital => 'Entrega no hospital registrada com sucesso.',
    };
    saveNotification(event.title, message);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _LatteShell(
      route: _route,
      navigate: _navigate,
      recordEvent: _recordEvent,
    );
  }
}

class _LatteShell extends StatelessWidget {
  const _LatteShell({
    required this.route,
    required this.navigate,
    required this.recordEvent,
  });

  final LatteRoute route;
  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xEFFFFFFF), Color(0xEFFBF7F0)],
          ),
        ),
        child: Column(
          children: [
            SiteHeader(navigate: navigate),
            Expanded(child: SingleChildScrollView(child: _buildPage())),
          ],
        ),
      ),
      // Assistente demonstrativo: respostas locais, sem IA clinica ou atendimento real.
      floatingActionButton: ChatbotLauncher(navigate: navigate),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPage() {
    return KeyedSubtree(
      key: ValueKey<LattePage>(route.page),
      child: switch (route.page) {
        LattePage.home => HomePage(navigate: navigate),
        LattePage.howItWorks => HowItWorksPage(navigate: navigate),
        LattePage.donate => DonorPage(
          navigate: navigate,
          recordEvent: recordEvent,
        ),
        LattePage.schedule => SchedulePage(
          navigate: navigate,
          recordEvent: recordEvent,
        ),
        LattePage.donationMode => DonationModePage(navigate: navigate),
        LattePage.hospitalDelivery => HospitalDeliveryPage(
          navigate: navigate,
          recordEvent: recordEvent,
        ),
        LattePage.donorConfirmed => DonorConfirmedPage(
          navigate: navigate,
          route: route,
        ),
        LattePage.scheduleConfirmed => ScheduleConfirmedPage(
          navigate: navigate,
          route: route,
        ),
        LattePage.request => RequestPage(
          navigate: navigate,
          recordEvent: recordEvent,
        ),
        LattePage.requestConfirmed => RequestConfirmedPage(
          navigate: navigate,
          route: route,
        ),
        LattePage.hospitals => HospitalsPage(
          navigate: navigate,
          recordEvent: recordEvent,
        ),
        LattePage.impact => ImpactPage(navigate: navigate),
        LattePage.guidance => GuidancePage(navigate: navigate),
        LattePage.journey => JourneyPage(navigate: navigate),
        LattePage.login => LoginPage(navigate: navigate),
        LattePage.dashboard => DashboardPage(navigate: navigate),
      },
    );
  }
}

class Section extends StatelessWidget {
  const Section({
    required this.child,
    this.top = 51,
    this.bottom = 51,
    super.key,
  });

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width <= 560 ? 16.0 : 24.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}

class SectionGrid extends StatelessWidget {
  const SectionGrid({
    required this.left,
    required this.right,
    this.top = 51,
    this.bottom = 51,
    this.minHeight,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.breakpoint = 1180,
    this.gap = 24,
    super.key,
  });

  final Widget left;
  final Widget right;
  final double top;
  final double bottom;
  final double? minHeight;
  final int leftFlex;
  final int rightFlex;
  final double breakpoint;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Section(
      top: top,
      bottom: bottom,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked =
              MediaQuery.sizeOf(context).width <= breakpoint ||
              constraints.maxWidth <= 900;
          final content = stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    left,
                    SizedBox(height: gap),
                    right,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: leftFlex, child: left),
                    SizedBox(width: gap),
                    Expanded(flex: rightFlex, child: right),
                  ],
                );

          if (minHeight == null) {
            return content;
          }

          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight!),
            child: content,
          );
        },
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    this.minItemWidth = 260,
    this.gap = 16,
    this.fullWidthIndexes = const <int>{},
    super.key,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double gap;
  final Set<int> fullWidthIndexes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= (minItemWidth * 2 + gap);
        final itemWidth = twoColumns
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var index = 0; index < children.length; index++)
              SizedBox(
                width: fullWidthIndexes.contains(index)
                    ? constraints.maxWidth
                    : itemWidth,
                child: children[index],
              ),
          ],
        );
      },
    );
  }
}

class SiteHeader extends StatelessWidget {
  const SiteHeader({required this.navigate, super.key});

  final NavigateTo navigate;

  static const List<(String, String)> links = [
    ('Como funciona', '/como-funciona'),
    ('Orientacao', '/orientacao'),
    ('Hospitais parceiros', '/hospitais'),
    ('Impacto', '/impacto'),
    ('Cadastro', '/doar'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width <= 820;
    final horizontal = width <= 560
        ? 16.0
        : width <= 1180
        ? 24.0
        : 60.0;

    return Container(
      constraints: const BoxConstraints(minHeight: _headerHeight),
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xF0FFFFFF),
        border: Border(bottom: BorderSide(color: Color(0xE6D9E5F2))),
      ),
      child: Row(
        children: [
          Logo(navigate: navigate),
          if (!mobile) ...[
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: width <= 1180 ? 12 : 22,
                children: [
                  for (final (label, path) in links)
                    _HeaderLink(label: label, onPressed: () => navigate(path)),
                ],
              ),
            ),
            Wrap(
              spacing: 12,
              children: [
                NotificationMenu(navigate: navigate),
                AppButton(
                  label: 'Entrar',
                  variant: ButtonVariant.ghost,
                  onPressed: () => navigate('/entrar'),
                ),
                AppButton(
                  label: 'Cadastrar',
                  onPressed: () => navigate('/doar'),
                ),
              ],
            ),
          ] else ...[
            const Spacer(),
            PopupMenuButton<String>(
              tooltip: 'Abrir menu',
              color: AppColors.surface,
              surfaceTintColor: AppColors.surface,
              onSelected: (path) => navigate(path),
              itemBuilder: (context) => [
                for (final (label, path) in links)
                  PopupMenuItem(value: path, child: Text(label)),
                const PopupMenuItem(
                  value: '/minha-jornada',
                  child: Text('Minha jornada'),
                ),
                const PopupMenuItem(value: '/entrar', child: Text('Entrar')),
              ],
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(_radius),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width <= 560;

    return InkWell(
      onTap: () => navigate('/'),
      borderRadius: BorderRadius.circular(_radius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _brandName,
              style: TextStyle(
                color: AppColors.blue,
                fontFamily: 'Georgia',
                fontSize: compact ? 27 : 32,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                height: 0.98,
                letterSpacing: 0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: compact ? 28 : 42, top: 2),
              child: Text(
                _brandCaption,
                style: TextStyle(
                  color: const Color(0xFF2687C7),
                  fontSize: compact ? 11.5 : 13,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationMenu extends StatelessWidget {
  const NotificationMenu({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    final notifications = getNotifications();
    return PopupMenuButton<void>(
      tooltip: 'Abrir notificacoes',
      offset: const Offset(0, 48),
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          enabled: false,
          child: SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Notificacoes',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (final notice in notifications.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${notice.title}\n${notice.message}',
                      style: AppText.paragraph,
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    navigate('/minha-jornada');
                  },
                  child: const Text('Ver minha jornada'),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Badge(
        label: Text('${notifications.length}'),
        child: IconButton(
          onPressed: null,
          icon: const Icon(Icons.notifications_none, color: AppColors.blue),
        ),
      ),
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blueDark,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      child: Text(label),
    );
  }
}

enum ButtonVariant { primary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.fullWidth = false,
    this.icon,
    this.minWidth,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final bool fullWidth;
  final IconData? icon;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == ButtonVariant.primary;
    final foreground = isPrimary ? Colors.white : AppColors.blue;

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          constraints: BoxConstraints(minHeight: 44, minWidth: minWidth ?? 0),
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary ? null : AppColors.surface,
            gradient: isPrimary
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0564BD), AppColors.blue],
                  )
                : null,
            border: Border.all(
              color: isPrimary ? Colors.transparent : AppColors.blue,
            ),
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: isPrimary
                ? const [
                    BoxShadow(
                      color: Color(0x33004F9F),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return SizedBox(width: fullWidth ? double.infinity : null, child: button);
  }
}

class SymbolIcon extends StatelessWidget {
  const SymbolIcon({
    required this.icon,
    this.color = AppColors.blue,
    this.background = AppColors.blueSoft,
    this.size = 58,
    super.key,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppText.eyebrow());
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.eyebrow,
    required this.title,
    this.description,
    this.compact = false,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String? description;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(eyebrow),
        const SizedBox(height: 10),
        Text(title, style: AppText.sectionTitle(compact ? 23 : 35)),
        if (description != null) ...[
          const SizedBox(height: 10),
          Text(description!, style: AppText.paragraph),
        ],
      ],
    );
  }
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    required this.eyebrow,
    required this.title,
    required this.description,
    this.actions,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final fontSize = width <= 560
        ? 34.0
        : width <= 820
        ? 39.0
        : 50.0;

    return Section(
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Text(title, style: AppText.title(fontSize)),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(description, style: AppText.lead),
          ),
          if (actions != null) ...[
            const SizedBox(height: 24),
            Wrap(spacing: 13, runSpacing: 13, children: actions!),
          ],
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width <= 560
        ? 34.0
        : width <= 820
        ? 39.0
        : 60.0;

    return Column(
      children: [
        SectionGrid(
          top: 35,
          bottom: 38,
          minHeight: math.max(0, viewportHeight - _headerHeight - 73),
          leftFlex: 11,
          rightFlex: 9,
          left: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Eyebrow('Leite humano - vida que conecta'),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: RichText(
                  text: TextSpan(
                    style: AppText.title(titleSize),
                    children: const [
                      TextSpan(
                        text: 'Conectando doadoras, hospitais e familias pelo ',
                      ),
                      TextSpan(
                        text: 'leite humano.',
                        style: TextStyle(color: AppColors.gold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: const Text(
                  'O LatteConect centraliza a jornada da doacao em uma experiencia simples: a nutriz se cadastra, escolhe a melhor janela de coleta, encontra a unidade parceira mais proxima e recebe orientacao segura durante o processo.',
                  style: AppText.lead,
                ),
              ),
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: const Text(
                  'Para os bancos de leite, o MVP organiza cadastros, estoque, alertas e demanda por regiao em telas separadas, prontas para demonstrar o funcionamento da solucao na Sprint 3.',
                  style: AppText.paragraph,
                ),
              ),
              const SizedBox(height: 18),
              const Wrap(
                spacing: 11,
                runSpacing: 11,
                children: [
                  InfoChip('Cadastro guiado'),
                  InfoChip('Coleta domiciliar'),
                  InfoChip('Rede parceira'),
                ],
              ),
            ],
          ),
          right: Container(
            padding: const EdgeInsets.all(20),
            decoration: _panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(3, 3, 3, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Acesse o MVP'),
                      const SizedBox(height: 8),
                      Text('Escolha o fluxo', style: AppText.sectionTitle(29)),
                    ],
                  ),
                ),
                ActionGrid(navigate: navigate),
              ],
            ),
          ),
        ),
        SectionGrid(
          left: const SectionHeading(
            eyebrow: 'Sprint 3',
            title: 'Fluxos separados em paginas proprias',
            description:
                'Cada area foi isolada para navegar como um produto real: explicacao do processo, cadastro de doadora, solicitacao de leite, busca de hospitais, impacto da doacao e entrada do gestor.',
          ),
          right: QuickLinks(
            links: [
              ('Ver como funciona', '/como-funciona'),
              ('Iniciar cadastro de doadora', '/doar'),
              ('Ver impacto da doacao', '/impacto'),
              ('Encontrar banco parceiro', '/hospitais'),
            ],
            navigate: navigate,
          ),
        ),
        ProcessOverview(navigate: navigate),
        Section(
          top: 24,
          bottom: 48,
          child: Center(
            child: AppButton(
              label: 'Painel',
              minWidth: 150,
              variant: ButtonVariant.ghost,
              onPressed: () => navigate('/painel'),
            ),
          ),
        ),
      ],
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.blueDark,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ActionGrid extends StatelessWidget {
  const ActionGrid({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      minItemWidth: 210,
      gap: 16,
      children: [
        for (final card in _actionCards)
          ActionCard(card: card, onPressed: () => navigate(card.path)),
      ],
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({required this.card, required this.onPressed, super.key});

  final ActionCardData card;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isGold = card.tone == 'gold';
    final softBlue = card.tone == 'blue-soft';
    final accent = isGold ? AppColors.gold : AppColors.blue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 118),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: softBlue ? const Color(0xD9E7F4FF) : const Color(0xE6FFFFFF),
            border: Border.all(color: AppColors.lineWarm),
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1414375C),
                blurRadius: 40,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              SymbolIcon(
                icon: card.icon,
                color: isGold ? Colors.white : AppColors.blue,
                background: isGold ? AppColors.gold : AppColors.blueSoft,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(card.title, style: AppText.sectionTitle(20)),
                    const SizedBox(height: 5),
                    Text(
                      card.description,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickLinks extends StatelessWidget {
  const QuickLinks({required this.links, required this.navigate, super.key});

  final List<(String, String)> links;
  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (label, path) in links) ...[
          _QuickLink(label: label, onPressed: () => navigate(path)),
          if ((label, path) != links.last) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_radius),
        child: Ink(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1214375C),
                blurRadius: 34,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.blueDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, color: AppColors.gold, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ProcessOverview extends StatelessWidget {
  const ProcessOverview({
    required this.navigate,
    this.detailed = false,
    super.key,
  });

  final NavigateTo navigate;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    if (detailed) {
      return Section(
        top: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              eyebrow: 'Jornada segura',
              title: 'Como funciona',
              description:
                  'O MVP organiza a doacao em uma jornada clara para nutrizes, hospitais e equipes gestoras.',
            ),
            const SizedBox(height: 22),
            ResponsiveGrid(
              minItemWidth: 280,
              gap: 16,
              children: [
                for (final step in _processSteps)
                  _ProcessStepCard(step: step, framed: true),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width <= 560 ? 16 : 24,
        vertical: 32,
      ),
      decoration: const BoxDecoration(
        color: Color(0xD1FFFFFF),
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.lineWarm),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth <= 900;
              final heading = const SectionHeading(
                eyebrow: 'Jornada segura',
                title: 'Como funciona',
                compact: true,
              );
              final steps = ResponsiveGrid(
                minItemWidth: 220,
                gap: 16,
                children: [
                  for (final step in _processSteps)
                    _ProcessStepCard(step: step, framed: false),
                ],
              );

              return stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [heading, const SizedBox(height: 20), steps],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 220, child: heading),
                        const SizedBox(width: 24),
                        Expanded(child: steps),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}

class _ProcessStepCard extends StatelessWidget {
  const _ProcessStepCard({required this.step, required this.framed});

  final (String, String, String) step;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final (number, title, description) = step;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.blueSoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.blue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.blueDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!framed) {
      return content;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: content,
    );
  }
}

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionGrid(
          left: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Como funciona'),
              const SizedBox(height: 12),
              Text(
                'Uma jornada simples para transformar doacao em atendimento.',
                style: AppText.title(
                  MediaQuery.sizeOf(context).width <= 560 ? 34 : 50,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'O MVP organiza a comunicacao entre nutrizes, bancos de leite, hospitais e familias, reduzindo friccao no cadastro e no agendamento de coletas.',
                style: AppText.lead,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Quero doar leite',
                onPressed: () => navigate('/doar'),
              ),
            ],
          ),
          right: const RoutePanel(
            labels: ['Cadastro', 'Agendamento', 'Triagem', 'Impacto'],
          ),
        ),
        ProcessOverview(navigate: navigate, detailed: true),
        Section(
          child: ResponsiveGrid(
            minItemWidth: 300,
            gap: 16,
            children: const [
              InfoCard(
                icon: Icons.people_alt_outlined,
                title: 'Cadastro acolhedor',
                text:
                    'A nutriz informa dados essenciais, contatos e disponibilidade para que a equipe parceira conduza a triagem.',
              ),
              InfoCard(
                icon: Icons.verified_user_outlined,
                title: 'Coleta segura',
                text:
                    'O banco de leite agenda a retirada, confirma endereco e orienta armazenamento antes da visita domiciliar.',
              ),
              InfoCard(
                icon: Icons.local_hospital_outlined,
                title: 'Gestao da rede',
                text:
                    'Hospitais acompanham estoque, demanda por regiao e cadastros pendentes em um painel operacional.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RoutePanel extends StatelessWidget {
  const RoutePanel({required this.labels, super.key});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(borderColor: AppColors.line),
      child: Column(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: index.isOdd
                    ? AppColors.surfaceWarm
                    : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(6),
                border: Border(
                  left: BorderSide(
                    color: index.isOdd ? AppColors.gold : AppColors.blue,
                    width: 4,
                  ),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                labels[index],
                style: const TextStyle(
                  color: AppColors.blueDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (index != labels.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.icon,
    required this.title,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 230),
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(borderColor: AppColors.line),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SymbolIcon(icon: icon),
          const SizedBox(height: 16),
          Text(title, style: AppText.sectionTitle(23)),
          const SizedBox(height: 10),
          Text(text, style: AppText.paragraph),
        ],
      ),
    );
  }
}

class DonorPage extends StatelessWidget {
  const DonorPage({
    required this.navigate,
    required this.recordEvent,
    super.key,
  });

  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageIntro(
          eyebrow: 'Quero doar leite',
          title: 'Cadastro de nutriz doadora',
          description:
              'Preencha o cadastro da nutriz. Ao finalizar, voce pode apenas salvar seus dados ou seguir para uma etapa separada de agendamento.',
          actions: [
            AppButton(
              label: 'Ja tenho cadastro e quero agendar',
              variant: ButtonVariant.ghost,
              onPressed: () => navigate('/doar/modalidade'),
            ),
          ],
        ),
        DonorRegistration(navigate: navigate, recordEvent: recordEvent),
      ],
    );
  }
}

class DonorRegistration extends StatefulWidget {
  const DonorRegistration({
    required this.navigate,
    required this.recordEvent,
    super.key,
  });

  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  State<DonorRegistration> createState() => _DonorRegistrationState();
}

class _DonorRegistrationState extends State<DonorRegistration> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _telefone;
  late final TextEditingController _email;
  late final TextEditingController _nascimento;
  late final TextEditingController _cep;
  late final TextEditingController _bairro;
  late final TextEditingController _endereco;
  late final TextEditingController _parto;
  String _estadoCivil = _defaultDonor['estadoCivil']!;
  String _medicamentos = _defaultDonor['medicamentos']!;
  bool _contatoAutorizado = true;
  bool _triagemAutorizada = true;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: _defaultDonor['nome']);
    _telefone = TextEditingController(text: _defaultDonor['telefone']);
    _email = TextEditingController(text: _defaultDonor['email']);
    _nascimento = TextEditingController(text: _defaultDonor['nascimento']);
    _cep = TextEditingController(text: _defaultDonor['cep']);
    _bairro = TextEditingController(text: _defaultDonor['bairro']);
    _endereco = TextEditingController(text: _defaultDonor['endereco']);
    _parto = TextEditingController(text: _defaultDonor['parto']);
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _email.dispose();
    _nascimento.dispose();
    _cep.dispose();
    _bairro.dispose();
    _endereco.dispose();
    _parto.dispose();
    super.dispose();
  }

  void _submit(String targetPath) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.recordEvent(
      createOperationalEvent(
        EventKind.cadastro,
        title: 'Cadastro de nutriz',
        subject: _read(_nome, _defaultDonor['nome']!),
        contact: _read(_telefone, _defaultDonor['telefone']!),
        location:
            '${_read(_bairro, _defaultDonor['bairro']!)} - ${_read(_cep, _defaultDonor['cep']!)}',
        date: 'Cadastro recebido',
        time: 'Triagem inicial',
        status: 'Em analise',
        statusTone: 'blue',
      ),
    );

    widget.navigate(
      targetPath,
      query: targetPath == '/doar/confirmado'
          ? {
              'protocolo': createProtocol('CAD'),
              'nome': _read(_nome, _defaultDonor['nome']!),
              'telefone': _read(_telefone, _defaultDonor['telefone']!),
              'bairro': _read(_bairro, _defaultDonor['bairro']!),
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionGrid(
      breakpoint: 1180,
      leftFlex: 36,
      rightFlex: 92,
      top: 24,
      left: const _DonorSideRail(),
      right: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: _panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormTitle(
                icon: Icons.people_alt_outlined,
                eyebrow: 'Cadastro completo',
                title: 'Dados da nutriz',
                description:
                    'Preencha as informacoes principais. Depois voce escolhe se quer apenas salvar o cadastro ou ja agendar uma coleta.',
              ),
              const SizedBox(height: 20),
              FormSection(
                number: '1',
                title: 'Dados pessoais',
                child: Column(
                  children: [
                    LabeledTextField(
                      label: 'Nome completo *',
                      controller: _nome,
                      required: true,
                      placeholder: 'Digite seu nome completo',
                    ),
                    const SizedBox(height: 16),
                    ResponsiveGrid(
                      children: [
                        LabeledTextField(
                          label: 'Telefone / WhatsApp *',
                          controller: _telefone,
                          required: true,
                          placeholder: '(00) 00000-0000',
                        ),
                        LabeledTextField(
                          label: 'E-mail',
                          controller: _email,
                          placeholder: 'seumail@exemplo.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        LabeledTextField(
                          label: 'Data de nascimento',
                          controller: _nascimento,
                        ),
                        LabeledDropdown(
                          label: 'Estado civil',
                          value: _estadoCivil,
                          items: const [
                            'Solteira',
                            'Casada',
                            'Uniao estavel',
                            'Outro',
                          ],
                          onChanged: (value) => setState(() {
                            _estadoCivil = value;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FormSection(
                number: '2',
                title: 'Endereco para coleta',
                child: ResponsiveGrid(
                  fullWidthIndexes: const {2},
                  children: [
                    LabeledTextField(
                      label: 'CEP *',
                      controller: _cep,
                      required: true,
                      placeholder: '00000-000',
                    ),
                    LabeledTextField(
                      label: 'Bairro',
                      controller: _bairro,
                      placeholder: 'Ex.: Vila Mariana',
                    ),
                    LabeledTextField(
                      label: 'Endereco completo *',
                      controller: _endereco,
                      required: true,
                      placeholder: 'Rua, numero, complemento',
                    ),
                  ],
                ),
              ),
              FormSection(
                number: '3',
                title: 'Informacoes de saude',
                child: ResponsiveGrid(
                  children: [
                    LabeledTextField(
                      label: 'Data aproximada do parto',
                      controller: _parto,
                    ),
                    LabeledDropdown(
                      label: 'Uso de medicamentos',
                      value: _medicamentos,
                      items: const [
                        'Nao',
                        'Sim, com acompanhamento medico',
                        'Prefiro informar por telefone',
                      ],
                      onChanged: (value) => setState(() {
                        _medicamentos = value;
                      }),
                    ),
                  ],
                ),
              ),
              FormSection(
                number: '4',
                title: 'Consentimento',
                child: Column(
                  children: [
                    ConsentCheckbox(
                      value: _contatoAutorizado,
                      label: 'Autorizo o contato do banco de leite parceiro.',
                      onChanged: (value) => setState(() {
                        _contatoAutorizado = value;
                      }),
                    ),
                    const SizedBox(height: 12),
                    ConsentCheckbox(
                      value: _triagemAutorizada,
                      label: 'Confirmo que aceito passar pela triagem inicial.',
                      onChanged: (value) => setState(() {
                        _triagemAutorizada = value;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const InlineAlert(
                icon: Icons.favorite_border,
                text:
                    'Todas as informacoes sao confidenciais e utilizadas apenas para cadastro, triagem e agendamento.',
              ),
              const SizedBox(height: 26),
              _ResponsiveActions(
                leading: AppButton(
                  label: 'Cancelar',
                  variant: ButtonVariant.ghost,
                  onPressed: () => widget.navigate('/'),
                ),
                trailing: [
                  AppButton(
                    label: 'Salvar cadastro',
                    variant: ButtonVariant.ghost,
                    onPressed: () => _submit('/doar/confirmado'),
                  ),
                  AppButton(
                    label: 'Salvar e agendar coleta ->',
                    onPressed: () => _submit('/doar/agendamento'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonorSideRail extends StatelessWidget {
  const _DonorSideRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SymbolIcon(icon: Icons.people_alt_outlined),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Cadastro de nutriz doadora',
                      style: TextStyle(
                        color: AppColors.blueDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Preencha os dados para iniciar a doacao.',
                      style: AppText.paragraph,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.line),
          const SizedBox(height: 20),
          for (final step in _formSteps) ...[
            _TimelineItem(step: step),
            if (step != _formSteps.last) const SizedBox(height: 18),
          ],
          const SizedBox(height: 24),
          const Divider(color: AppColors.line),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SymbolIcon(icon: Icons.verified_user_outlined, size: 44),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Dados usados apenas para triagem, contato e agendamento da coleta.',
                  style: AppText.paragraph,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.step});

  final (String, String, String) step;

  @override
  Widget build(BuildContext context) {
    final (number, title, description) = step;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: AppColors.blue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.blueDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: AppText.paragraph),
            ],
          ),
        ),
      ],
    );
  }
}

class FormTitle extends StatelessWidget {
  const FormTitle({
    required this.icon,
    required this.eyebrow,
    required this.title,
    this.description,
    super.key,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SymbolIcon(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(eyebrow),
                const SizedBox(height: 8),
                Text(title, style: AppText.sectionTitle(35)),
                if (description != null) ...[
                  const SizedBox(height: 10),
                  Text(description!, style: AppText.paragraph),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  const FormSection({
    required this.number,
    required this.title,
    required this.child,
    super.key,
  });

  final String number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.blueDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    required this.label,
    required this.controller,
    this.placeholder,
    this.required = false,
    this.keyboardType,
    this.obscureText = false,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final bool required;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: required
              ? (value) => value == null || value.trim().isEmpty
                    ? 'Campo obrigatorio'
                    : null
              : null,
          decoration: _fieldDecoration(placeholder),
          style: const TextStyle(color: AppColors.ink),
        ),
      ],
    );
  }
}

class LabeledDropdown extends StatelessWidget {
  const LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          decoration: _fieldDecoration(null),
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration(String? placeholder) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(_radius),
    borderSide: const BorderSide(color: Color(0xFF9BBCE2)),
  );

  return InputDecoration(
    hintText: placeholder,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.blue, width: 1.4),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: Color(0xFFC34242), width: 1.2),
    ),
  );
}

class ConsentCheckbox extends StatelessWidget {
  const ConsentCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(_radius),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked ?? false),
              activeColor: AppColors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: AppText.label)),
          ],
        ),
      ),
    );
  }
}

class InlineAlert extends StatelessWidget {
  const InlineAlert({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        border: Border.all(color: AppColors.lineWarm),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        children: [
          SymbolIcon(
            icon: icon,
            color: AppColors.gold,
            background: AppColors.surface,
            size: 42,
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: AppText.paragraph)),
        ],
      ),
    );
  }
}

class _ResponsiveActions extends StatelessWidget {
  const _ResponsiveActions({required this.leading, required this.trailing});

  final Widget leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width <= 820;
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: double.infinity, child: leading),
          const SizedBox(height: 12),
          for (final action in trailing) ...[
            SizedBox(width: double.infinity, child: action),
            if (action != trailing.last) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leading,
        Flexible(
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 12,
            children: trailing,
          ),
        ),
      ],
    );
  }
}

String _read(TextEditingController controller, String fallback) {
  final text = controller.text.trim();
  return text.isEmpty ? fallback : text;
}

class DonationModePage extends StatelessWidget {
  const DonationModePage({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageIntro(
          eyebrow: 'Formas de doar',
          title: 'Escolha como prefere contribuir',
          description:
              'As duas modalidades passam por orientacao e confirmacao da unidade parceira.',
        ),
        Section(
          top: 8,
          bottom: 48,
          child: ResponsiveGrid(
            minItemWidth: 340,
            children: [
              ModeChoiceCard(
                icon: Icons.home_outlined,
                title: 'Coleta domiciliar',
                text:
                    'Escolha uma janela para a equipe retirar o leite no endereco informado.',
                action: 'Agendar coleta em casa',
                onPressed: () => navigate('/doar/agendamento'),
              ),
              ModeChoiceCard(
                icon: Icons.local_hospital_outlined,
                title: 'Entrega no hospital',
                text:
                    'Leve sua doacao a uma unidade parceira, com horario e protocolo de entrega.',
                action: 'Agendar entrega no hospital',
                onPressed: () => navigate('/doar/entrega-hospital'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ModeChoiceCard extends StatelessWidget {
  const ModeChoiceCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.action,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(26),
    decoration: _panelDecoration(borderColor: AppColors.line),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SymbolIcon(icon: icon),
        const SizedBox(height: 18),
        Text(title, style: AppText.sectionTitle(28)),
        const SizedBox(height: 10),
        Text(text, style: AppText.paragraph),
        const SizedBox(height: 22),
        AppButton(label: action, onPressed: onPressed),
      ],
    ),
  );
}

class HospitalDeliveryPage extends StatefulWidget {
  const HospitalDeliveryPage({
    required this.navigate,
    required this.recordEvent,
    super.key,
  });

  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  State<HospitalDeliveryPage> createState() => _HospitalDeliveryPageState();
}

class _HospitalDeliveryPageState extends State<HospitalDeliveryPage> {
  late final TextEditingController _nome;
  late final TextEditingController _telefone;
  String _hospital = _hospitals.first.name;
  String _horario = _timeSlots[1];

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: _defaultSchedule.nome);
    _telefone = TextEditingController(text: _defaultSchedule.telefone);
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    super.dispose();
  }

  void _submit() {
    final protocol = createProtocol('ENT');
    widget.recordEvent(
      createOperationalEvent(
        EventKind.hospital,
        title: 'Entrega no hospital agendada',
        subject: _read(_nome, _defaultSchedule.nome),
        contact: _read(_telefone, _defaultSchedule.telefone),
        location: _hospital,
        date: '28 de maio de 2026',
        time: _horario,
        status: 'Confirmado',
        statusTone: 'green',
      ),
    );
    widget.navigate(
      '/doar/agendamento-confirmado',
      query: {
        'protocolo': protocol,
        'data': '2026-05-28',
        'horario': _horario,
        'hospital': _hospital,
        'telefone': _read(_telefone, _defaultSchedule.telefone),
        'modalidade': 'Entrega no hospital',
      },
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const PageIntro(
        eyebrow: 'Entrega presencial',
        title: 'Agende sua entrega no hospital',
        description:
            'Escolha uma unidade parceira. Leve o protocolo no dia para facilitar a identificacao da doacao.',
      ),
      Section(
        top: 8,
        bottom: 48,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 780),
          padding: const EdgeInsets.all(28),
          decoration: _panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InlineAlert(
                text:
                    'Demonstracao: confirme com a unidade parceira os criterios e horarios reais antes de se deslocar.',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 20),
              LabeledTextField(
                label: 'Nome da nutriz *',
                controller: _nome,
                required: true,
              ),
              const SizedBox(height: 16),
              LabeledTextField(
                label: 'Telefone / WhatsApp *',
                controller: _telefone,
                required: true,
              ),
              const SizedBox(height: 16),
              LabeledDropdown(
                label: 'Hospital parceiro',
                value: _hospital,
                items: _hospitals.map((item) => item.name).toList(),
                onChanged: (value) => setState(() => _hospital = value),
              ),
              const SizedBox(height: 16),
              LabeledDropdown(
                label: 'Horario de entrega',
                value: _horario,
                items: _timeSlots,
                onChanged: (value) => setState(() => _horario = value),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Confirmar entrega e gerar protocolo',
                fullWidth: true,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class GuidancePage extends StatelessWidget {
  const GuidancePage({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      PageIntro(
        eyebrow: 'Orientacao e apoio',
        title: 'Informacao para quem quer cuidar, mesmo sem doar',
        description:
            'Encontre orientacoes educativas sobre amamentacao, doacao e acesso a rede de apoio.',
        actions: [
          AppButton(
            label: 'Encontrar hospital parceiro',
            variant: ButtonVariant.ghost,
            onPressed: () => navigate('/hospitais'),
          ),
        ],
      ),
      Section(
        top: 8,
        bottom: 48,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InlineAlert(
              text:
                  'Conteudo educativo. Nao substitui avaliacao de profissionais de saude. Em urgencia, procure atendimento imediato.',
              icon: Icons.health_and_safety_outlined,
            ),
            const SizedBox(height: 24),
            Text('Duvidas frequentes', style: AppText.sectionTitle(31)),
            const SizedBox(height: 12),
            for (final item in const [
              (
                'Quem pode receber orientacao?',
                'Qualquer pessoa pode consultar estas informacoes e buscar uma unidade parceira, mesmo sem interesse em doar.',
              ),
              (
                'Como sei se posso doar leite?',
                'A elegibilidade e confirmada pela equipe do banco de leite. O cadastro e apenas o primeiro passo da triagem.',
              ),
              (
                'Como armazenar o leite?',
                'Siga sempre as instrucoes atualizadas do banco de leite responsavel antes de coletar, armazenar ou transportar.',
              ),
              (
                'Quando procurar ajuda profissional?',
                'Se houver dor, febre, dificuldade para amamentar ou preocupacao com o bebe, procure uma unidade de saude.',
              ),
            ])
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: _panelDecoration(borderColor: AppColors.line),
                child: Material(
                  color: Colors.transparent,
                  child: ExpansionTile(
                    title: Text(item.$1, style: AppText.label),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    children: [Text(item.$2, style: AppText.paragraph)],
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class JourneyPage extends StatelessWidget {
  const JourneyPage({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    final events = getOperationalEvents();
    return Column(
      children: [
        PageIntro(
          eyebrow: 'Minha jornada',
          title: 'Cada passo fortalece a rede de cuidado',
          description:
              'Acompanhamento demonstrativo dos seus protocolos, marcos e impacto estimado.',
          actions: [
            AppButton(
              label: 'Nova doacao',
              onPressed: () => navigate('/doar/modalidade'),
            ),
          ],
        ),
        Section(
          top: 8,
          bottom: 48,
          child: ResponsiveGrid(
            minItemWidth: 270,
            children: const [
              InfoCard(
                icon: Icons.workspace_premium_outlined,
                title: 'Primeiro passo',
                text: 'Selo liberado ao concluir o cadastro de doadora.',
              ),
              InfoCard(
                icon: Icons.favorite_outline,
                title: 'Rede de cuidado',
                text:
                    'Progresso demonstrativo: 1 de 3 contribuicoes para o proximo marco.',
              ),
              InfoCard(
                icon: Icons.volunteer_activism_outlined,
                title: 'Impacto estimado',
                text:
                    'Sua participacao ajuda a aproximar leite humano de bebes que precisam.',
              ),
            ],
          ),
        ),
        Section(
          top: 0,
          bottom: 48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Atividades recentes', style: AppText.sectionTitle(30)),
              const SizedBox(height: 16),
              for (final event in events.take(5))
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(18),
                  decoration: _panelDecoration(borderColor: AppColors.line),
                  child: Row(
                    children: [
                      SymbolIcon(
                        icon: event.kind == EventKind.hospital
                            ? Icons.local_hospital_outlined
                            : Icons.verified_outlined,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: AppText.label),
                            Text(
                              '${event.date} - ${event.time}',
                              style: AppText.paragraph,
                            ),
                          ],
                        ),
                      ),
                      StatusPill(label: event.status, tone: event.statusTone),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatbotLauncher extends StatelessWidget {
  const ChatbotLauncher({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    heroTag: 'chatbot',
    backgroundColor: AppColors.blue,
    foregroundColor: Colors.white,
    icon: const Icon(Icons.auto_awesome_outlined),
    label: const Text('Precisa de ajuda?'),
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatbotPanel(navigate: navigate),
    ),
  );
}

class ChatbotPanel extends StatefulWidget {
  const ChatbotPanel({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  State<ChatbotPanel> createState() => _ChatbotPanelState();
}

class _ChatbotPanelState extends State<ChatbotPanel> {
  String _answer =
      'Oi! Sou a Luna, assistente demonstrativa do LatteConect. Posso ajudar com orientacoes e encaminhar voce para uma area do site.';

  void _respond(String question) {
    setState(() {
      _answer = switch (question) {
        'Posso doar?' =>
          'A elegibilidade e confirmada pela equipe do banco de leite. Posso levar voce ao cadastro para iniciar a triagem educativa.',
        'Como armazenar?' =>
          'Para armazenar ou transportar leite, siga a orientacao atualizada da unidade parceira. Posso abrir a area de apoio.',
        'Entrega no hospital' =>
          'Voce pode escolher uma unidade parceira e agendar uma entrega presencial com protocolo demonstrativo.',
        _ =>
          'Para duvidas de saude, dor, febre ou preocupacao com o bebe, procure uma unidade de saude. Este assistente nao realiza diagnosticos.',
      };
    });
  }

  void _go(String path) {
    Navigator.of(context).pop();
    widget.navigate(path);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SymbolIcon(icon: Icons.auto_awesome_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Luna, assistente de orientacao',
                  style: AppText.sectionTitle(22),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(_answer, style: AppText.paragraph),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in const [
                'Posso doar?',
                'Como armazenar?',
                'Entrega no hospital',
                'Preciso de ajuda',
              ])
                OutlinedButton(
                  onPressed: () => _respond(option),
                  child: Text(option),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Este e um assistente educativo demonstrativo; ele nao faz consultas, diagnosticos ou atendimento de emergencia.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: 'Ver orientacoes',
                variant: ButtonVariant.ghost,
                onPressed: () => _go('/orientacao'),
              ),
              AppButton(label: 'Quero doar', onPressed: () => _go('/doar')),
            ],
          ),
        ],
      ),
    ),
  );
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({
    required this.navigate,
    required this.recordEvent,
    super.key,
  });

  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageIntro(
          eyebrow: 'Agendamento',
          title: 'Agendamento de coleta domiciliar',
          description:
              'Esta etapa e independente do cadastro. A nutriz pode voltar quando quiser para escolher uma janela de coleta.',
        ),
        SchedulePanel(navigate: navigate, recordEvent: recordEvent),
      ],
    );
  }
}

class SchedulePanel extends StatefulWidget {
  const SchedulePanel({
    required this.navigate,
    required this.recordEvent,
    super.key,
  });

  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  State<SchedulePanel> createState() => _SchedulePanelState();
}

class _SchedulePanelState extends State<SchedulePanel> {
  late final TextEditingController _nome;
  late final TextEditingController _telefone;
  late final TextEditingController _cep;
  late final TextEditingController _data;
  String _hospital = _defaultSchedule.hospital;
  String _horario = _defaultSchedule.horario;

  @override
  void initState() {
    super.initState();
    var nome = _defaultSchedule.nome;
    var telefone = _defaultSchedule.telefone;
    var cep = _defaultSchedule.cep;

    final latestDonor = getStoredOperationalEvents()
        .where((event) => event.kind == EventKind.cadastro)
        .firstOrNull;

    if (latestDonor != null) {
      nome = latestDonor.subject;
      telefone = latestDonor.contact;
      final cepMatch = RegExp(r'\d{5}-\d{3}').firstMatch(latestDonor.location);
      cep = cepMatch?.group(0) ?? cep;
    }

    _nome = TextEditingController(text: nome);
    _telefone = TextEditingController(text: telefone);
    _cep = TextEditingController(text: cep);
    _data = TextEditingController(text: _defaultSchedule.data);
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _cep.dispose();
    _data.dispose();
    super.dispose();
  }

  void _setDate(String date) {
    setState(() {
      _data.text = date;
    });
  }

  void _submit() {
    final date = _read(_data, _defaultSchedule.data);
    widget.recordEvent(
      createOperationalEvent(
        EventKind.coleta,
        title: 'Coleta agendada',
        subject: _read(_nome, _defaultSchedule.nome),
        contact: _read(_telefone, _defaultSchedule.telefone),
        location: _read(_cep, _defaultSchedule.cep),
        date: formatLongDate(date),
        time: _horario,
        status: 'Confirmado',
        statusTone: 'green',
      ),
    );

    widget.navigate(
      '/doar/agendamento-confirmado',
      query: {
        'protocolo': createProtocol('COL'),
        'data': date,
        'horario': _horario,
        'telefone': _read(_telefone, _defaultSchedule.telefone),
        'hospital': _hospital,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateLabel = formatLongDate(_data.text);

    return SectionGrid(
      breakpoint: 1180,
      leftFlex: 100,
      rightFlex: 39,
      top: 24,
      left: Container(
        padding: const EdgeInsets.all(28),
        decoration: _panelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              eyebrow: 'Coleta domiciliar',
              title: 'Agendamento da coleta',
              description:
                  'Informe seu cadastro e escolha data, horario e unidade responsavel pela retirada segura do leite.',
            ),
            const SizedBox(height: 18),
            ResponsiveGrid(
              fullWidthIndexes: const {4},
              children: [
                LabeledTextField(
                  label: 'Nome da nutriz *',
                  controller: _nome,
                  required: true,
                  placeholder: 'Nome completo',
                ),
                LabeledTextField(
                  label: 'Telefone da nutriz *',
                  controller: _telefone,
                  required: true,
                  placeholder: '(00) 00000-0000',
                ),
                LabeledTextField(
                  label: 'CEP da coleta *',
                  controller: _cep,
                  required: true,
                  placeholder: '00000-000',
                ),
                LabeledTextField(
                  label: 'Data da coleta *',
                  controller: _data,
                  required: true,
                ),
                LabeledDropdown(
                  label: 'Hospital responsavel',
                  value: _hospital,
                  items: _hospitals.map((hospital) => hospital.name).toList(),
                  onChanged: (value) => setState(() {
                    _hospital = value;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 740;
                final calendar = CalendarPicker(
                  selectedDate: _data.text,
                  onDateSelected: _setDate,
                );
                final slots = TimeSlots(
                  selectedDateLabel: selectedDateLabel,
                  selectedSlot: _horario,
                  onSlotSelected: (value) => setState(() {
                    _horario = value;
                  }),
                );

                return stacked
                    ? Column(
                        children: [calendar, const SizedBox(height: 20), slots],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 95, child: calendar),
                          const SizedBox(width: 20),
                          Expanded(flex: 70, child: slots),
                        ],
                      );
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(_radius),
              ),
              child: const Text(
                'A coleta tem duracao media de 30 a 40 minutos.',
                style: AppText.paragraph,
              ),
            ),
          ],
        ),
      ),
      right: SummaryPanel(
        selectedDateLabel: selectedDateLabel,
        selectedSlot: _horario,
        cep: _read(_cep, _defaultSchedule.cep),
        hospital: _hospital,
        onSubmit: _submit,
      ),
    );
  }
}

class CalendarPicker extends StatelessWidget {
  const CalendarPicker({
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  final String selectedDate;
  final ValueChanged<String> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CalendarArrow(icon: Icons.chevron_left, onPressed: () {}),
              const Text(
                'Maio 2026',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _CalendarArrow(icon: Icons.chevron_right, onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Weekday('D'),
              _Weekday('S'),
              _Weekday('T'),
              _Weekday('Q'),
              _Weekday('Q'),
              _Weekday('S'),
              _Weekday('S'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1,
            children: [
              for (final day in _calendarDays)
                _DayButton(
                  day: day,
                  selected: selectedDate == day.iso,
                  onPressed: () => onDateSelected(day.iso),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      icon: Icon(icon, color: AppColors.blue),
    );
  }
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.day,
    required this.selected,
    required this.onPressed,
  });

  final CalendarDay day;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: selected
            ? AppColors.blue
            : day.muted
            ? const Color(0xFFF6F8FB)
            : AppColors.surface,
        foregroundColor: selected
            ? Colors.white
            : day.muted
            ? const Color(0xFF9AA9BB)
            : AppColors.ink,
        side: BorderSide(color: selected ? AppColors.blue : AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(day.label),
    );
  }
}

class TimeSlots extends StatelessWidget {
  const TimeSlots({
    required this.selectedDateLabel,
    required this.selectedSlot,
    required this.onSlotSelected,
    super.key,
  });

  final String selectedDateLabel;
  final String selectedSlot;
  final ValueChanged<String> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horarios disponiveis',
            style: TextStyle(
              color: AppColors.blueDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedDateLabel,
            style: const TextStyle(color: AppColors.blue),
          ),
          const SizedBox(height: 16),
          ResponsiveGrid(
            minItemWidth: 110,
            gap: 12,
            children: [
              for (final slot in _timeSlots)
                _SlotButton(
                  slot: slot,
                  selected: slot == selectedSlot,
                  onPressed: () => onSlotSelected(slot),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({
    required this.slot,
    required this.selected,
    required this.onPressed,
  });

  final String slot;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: selected ? AppColors.blue : AppColors.surface,
        foregroundColor: selected ? Colors.white : AppColors.ink,
        side: BorderSide(color: selected ? AppColors.blue : AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(slot),
    );
  }
}

class SummaryPanel extends StatelessWidget {
  const SummaryPanel({
    required this.selectedDateLabel,
    required this.selectedSlot,
    required this.cep,
    required this.hospital,
    required this.onSubmit,
    super.key,
  });

  final String selectedDateLabel;
  final String selectedSlot;
  final String cep;
  final String hospital;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(_radius),
            ),
            child: const Row(
              children: [
                SymbolIcon(
                  icon: Icons.verified_user_outlined,
                  background: AppColors.surface,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coleta segura e confiavel',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Equipes seguem protocolos de transporte e armazenamento.',
                        style: AppText.paragraph,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Resumo da coleta', style: AppText.sectionTitle(24)),
          const SizedBox(height: 8),
          SummaryList(
            items: [
              ('Data', selectedDateLabel),
              ('Horario', selectedSlot),
              ('Endereco', 'CEP $cep'),
              ('Hospital responsavel', hospital),
            ],
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Confirmar agendamento ->',
            fullWidth: true,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class SummaryList extends StatelessWidget {
  const SummaryList({required this.items, super.key});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (label, value) in items)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.label),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: AppColors.ink, height: 1.35),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class DonorConfirmedPage extends StatelessWidget {
  const DonorConfirmedPage({
    required this.navigate,
    required this.route,
    super.key,
  });

  final NavigateTo navigate;
  final LatteRoute route;

  @override
  Widget build(BuildContext context) {
    return ConfirmationState(
      navigate: navigate,
      description:
          'Recebemos os dados da nutriz. A equipe do banco de leite parceiro fara a triagem inicial antes da primeira coleta.',
      details: [
        ('Status', 'Cadastro recebido'),
        ('Protocolo', _param(route, 'protocolo', 'LTC-CAD-260910-0000')),
        ('Nutriz', _param(route, 'nome', 'Marina Santos')),
        ('Telefone', _param(route, 'telefone', 'Telefone informado')),
        ('Bairro', _param(route, 'bairro', 'Vila Clementino')),
        ('Proximo passo', 'Aguardar contato do banco parceiro'),
        ('Retorno estimado', 'Ate 24 horas uteis'),
      ],
      eyebrow: 'Cadastro confirmado',
      primaryAction: ('/doar/modalidade', 'Escolher forma de doacao'),
      secondaryAction: ('/minha-jornada', 'Ver minha jornada'),
      title: 'Cadastro recebido com sucesso',
    );
  }
}

class ScheduleConfirmedPage extends StatelessWidget {
  const ScheduleConfirmedPage({
    required this.navigate,
    required this.route,
    super.key,
  });

  final NavigateTo navigate;
  final LatteRoute route;

  @override
  Widget build(BuildContext context) {
    final date = _param(route, 'data', '2026-05-28');

    return ConfirmationState(
      navigate: navigate,
      icon: Icons.verified_user_outlined,
      description:
          'Sua janela de coleta foi registrada. A unidade parceira confirma os detalhes por telefone antes da visita domiciliar.',
      details: [
        ('Status', 'Agendamento confirmado'),
        ('Protocolo', _param(route, 'protocolo', 'LTC-COL-260910-0000')),
        ('Data prevista', formatLongDate(date)),
        ('Horario', _param(route, 'horario', '09:00 - 10:00')),
        (
          'Hospital responsavel',
          _param(route, 'hospital', 'Unidade parceira mais proxima'),
        ),
        (
          'Contato',
          _param(route, 'telefone', 'Confirmacao por telefone ou WhatsApp'),
        ),
      ],
      eyebrow: 'Coleta confirmada',
      primaryAction: ('/minha-jornada', 'Ver minha jornada'),
      secondaryAction: ('/impacto', 'Ver impacto da doacao'),
      title: 'Agendamento confirmado',
    );
  }
}

class RequestPage extends StatelessWidget {
  const RequestPage({
    required this.navigate,
    required this.recordEvent,
    super.key,
  });

  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageIntro(
          eyebrow: 'Preciso de doacao',
          title: 'Solicitacao guiada para familias e hospitais',
          description:
              'Registre uma solicitacao de leite humano e acompanhe o retorno da rede parceira.',
        ),
        RequestForm(navigate: navigate, recordEvent: recordEvent),
      ],
    );
  }
}

class RequestForm extends StatefulWidget {
  const RequestForm({
    required this.navigate,
    required this.recordEvent,
    super.key,
  });

  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  late final TextEditingController _solicitante;
  late final TextEditingController _telefone;
  late final TextEditingController _email;
  late final TextEditingController _paciente;
  String _perfil = _defaultRequest['perfil']!;
  String _urgencia = _defaultRequest['urgencia']!;

  @override
  void initState() {
    super.initState();
    _solicitante = TextEditingController(text: _defaultRequest['solicitante']);
    _telefone = TextEditingController(text: _defaultRequest['telefone']);
    _email = TextEditingController(text: _defaultRequest['email']);
    _paciente = TextEditingController(text: _defaultRequest['paciente']);
  }

  @override
  void dispose() {
    _solicitante.dispose();
    _telefone.dispose();
    _email.dispose();
    _paciente.dispose();
    super.dispose();
  }

  void _submit() {
    widget.recordEvent(
      createOperationalEvent(
        EventKind.pedido,
        title: 'Pedido de leite enviado',
        subject: _read(_solicitante, _defaultRequest['solicitante']!),
        contact: _read(_telefone, _defaultRequest['telefone']!),
        location: _perfil,
        date: _read(_paciente, _defaultRequest['paciente']!),
        time: _urgencia,
        status: 'Em triagem',
        statusTone: 'blue',
      ),
    );

    widget.navigate(
      '/solicitar/confirmado',
      query: {
        'protocolo': createProtocol('PED'),
        'solicitante': _read(_solicitante, _defaultRequest['solicitante']!),
        'telefone': _read(_telefone, _defaultRequest['telefone']!),
        'perfil': _perfil,
        'paciente': _read(_paciente, _defaultRequest['paciente']!),
        'urgencia': _urgencia,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionGrid(
      breakpoint: 1180,
      leftFlex: 85,
      rightFlex: 70,
      left: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Eyebrow('Acolhimento'),
          SizedBox(height: 12),
          Text(
            'Solicitacao de leite humano',
            style: TextStyle(
              color: AppColors.blueDark,
              fontFamily: 'Georgia',
              fontSize: 41,
              fontWeight: FontWeight.w700,
              height: 1.12,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'O fluxo para familias e hospitais prioriza clareza, urgencia e direcionamento para a unidade responsavel, sem expor dados sensiveis.',
            style: AppText.paragraph,
          ),
          SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              InfoChip('Triagem inicial'),
              InfoChip('Contato do banco parceiro'),
              InfoChip('Historico de atendimento'),
            ],
          ),
        ],
      ),
      right: Container(
        padding: const EdgeInsets.all(28),
        decoration: _panelDecoration(),
        child: Column(
          children: [
            LabeledTextField(
              label: 'Nome do solicitante *',
              controller: _solicitante,
              required: true,
              placeholder: 'Nome completo',
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'Telefone / WhatsApp *',
              controller: _telefone,
              required: true,
              placeholder: '(00) 00000-0000',
            ),
            const SizedBox(height: 16),
            LabeledDropdown(
              label: 'Perfil',
              value: _perfil,
              items: const ['Familia', 'Hospital', 'Banco de leite'],
              onChanged: (value) => setState(() {
                _perfil = value;
              }),
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'E-mail',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              placeholder: 'contato@exemplo.com',
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'Nome do bebe ou paciente',
              controller: _paciente,
              placeholder: 'Opcional',
            ),
            const SizedBox(height: 16),
            LabeledDropdown(
              label: 'Prioridade',
              value: _urgencia,
              items: const [
                'Alta - UTI neonatal',
                'Media - acompanhamento hospitalar',
                'Baixa - orientacao',
              ],
              onChanged: (value) => setState(() {
                _urgencia = value;
              }),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Enviar solicitacao',
              fullWidth: true,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class RequestConfirmedPage extends StatelessWidget {
  const RequestConfirmedPage({
    required this.navigate,
    required this.route,
    super.key,
  });

  final NavigateTo navigate;
  final LatteRoute route;

  @override
  Widget build(BuildContext context) {
    return ConfirmationState(
      navigate: navigate,
      icon: Icons.local_drink_outlined,
      description:
          'A solicitacao foi registrada e encaminhada para a rede parceira. O contato informado sera usado para retorno e orientacao.',
      details: [
        ('Status', 'Solicitacao enviada'),
        ('Protocolo', _param(route, 'protocolo', 'LTC-PED-260910-0000')),
        ('Solicitante', _param(route, 'solicitante', 'Renata Alves')),
        (
          'Canal de retorno',
          _param(route, 'telefone', 'Telefone ou WhatsApp informado'),
        ),
        ('Perfil', _param(route, 'perfil', 'Familia')),
        ('Paciente', _param(route, 'paciente', 'Livia Alves')),
        ('Triagem', _param(route, 'urgencia', 'Alta - UTI neonatal')),
      ],
      eyebrow: 'Solicitacao confirmada',
      primaryAction: ('/hospitais', 'Ver hospitais parceiros'),
      secondaryAction: ('/painel', 'Ver painel gestor'),
      title: 'Solicitacao enviada',
    );
  }
}

class HospitalsPage extends StatelessWidget {
  const HospitalsPage({
    required this.navigate,
    required this.recordEvent,
    super.key,
  });

  final NavigateTo navigate;
  final RecordEvent recordEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageIntro(
          eyebrow: 'Hospitais parceiros',
          title: 'Encontre a unidade mais adequada para coleta ou atendimento',
          description:
              'Busque por CEP, veja unidades proximas e acompanhe a leitura de demanda por regiao.',
        ),
        HospitalsFinder(recordEvent: recordEvent),
      ],
    );
  }
}

class HospitalsFinder extends StatefulWidget {
  const HospitalsFinder({required this.recordEvent, super.key});

  final RecordEvent recordEvent;

  @override
  State<HospitalsFinder> createState() => _HospitalsFinderState();
}

class _HospitalsFinderState extends State<HospitalsFinder> {
  late final TextEditingController _cep;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _cep = TextEditingController(text: _defaultDonor['cep']);
  }

  @override
  void dispose() {
    _cep.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _hasSearched = true;
    });
    widget.recordEvent(
      createOperationalEvent(
        EventKind.hospital,
        title: 'Busca de hospital parceiro',
        subject: 'Consulta Vila Mariana',
        contact: 'Sem contato',
        location: _read(_cep, _defaultDonor['cep']!),
        date: 'Mapa de calor aberto',
        time: '5 hospitais proximos',
        status: 'Consulta feita',
        statusTone: 'gold',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Rede parceira',
            title: 'Pontos de coleta por CEP',
            description:
                'Consulte bancos de leite proximos, disponibilidade de estoque e areas com maior necessidade de doacao.',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth <= 900;
              final cepPanel = _CepPanel(
                controller: _cep,
                hasSearched: _hasSearched,
                onSearch: _search,
              );
              final list = const HospitalList();

              return stacked
                  ? Column(
                      children: [cepPanel, const SizedBox(height: 22), list],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 72, child: cepPanel),
                        const SizedBox(width: 22),
                        Expanded(flex: 100, child: list),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _CepPanel extends StatelessWidget {
  const _CepPanel({
    required this.controller,
    required this.hasSearched,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool hasSearched;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width <= 560;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Consultar por CEP', style: AppText.label),
          const SizedBox(height: 10),
          mobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledTextField(
                      label: '',
                      controller: controller,
                      placeholder: '04567-000',
                    ),
                    const SizedBox(height: 12),
                    AppButton(label: 'Buscar', onPressed: onSearch),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: _fieldDecoration('04567-000'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton(label: 'Buscar', onPressed: onSearch),
                  ],
                ),
          const SizedBox(height: 20),
          HeatMap(hasSearched: hasSearched),
        ],
      ),
    );
  }
}

class HeatMap extends StatelessWidget {
  const HeatMap({required this.hasSearched, super.key});

  final bool hasSearched;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(_radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasSearched ? const _HeatMapFilled() : const SizedBox.expand(),
    );
  }
}

class _HeatMapFilled extends StatelessWidget {
  const _HeatMapFilled();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const mapHeight = 360.0;
        final children = <Widget>[
          const Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
          const Positioned(top: 36, left: 72, child: _MapLabel('Santa Cruz')),
          const Positioned(
            right: 32,
            bottom: 36,
            child: _MapLabel('Vila Clementino'),
          ),
          const Positioned(
            top: 162,
            left: 36,
            child: Text(
              'Vila Mariana',
              style: TextStyle(
                color: Color(0x4D00346F),
                fontFamily: 'Georgia',
                fontSize: 35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const _MapRoad(
            top: 90,
            left: -42,
            widthFactor: 1.22,
            angle: -0.157,
            label: 'Rua Vergueiro',
          ),
          const _MapRoad(
            top: 202,
            left: -50,
            widthFactor: 1.24,
            angle: 0.209,
            label: 'Domingos de Morais',
          ),
          const _MapRoad(
            top: 136,
            left: 120,
            widthFactor: 0.88,
            angle: 1.257,
            label: 'Napoleao de Barros',
          ),
        ];

        for (final hospital in _hospitals) {
          final size = hospital.intensity == 5 ? 210.0 : 170.0;
          children.add(
            Positioned(
              left: constraints.maxWidth * hospital.x / 100 - size / 2,
              top: mapHeight * hospital.y / 100 - size / 2,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withAlpha(
                        hospital.intensity == 5 ? 138 : 92,
                      ),
                      AppColors.sky.withAlpha(92),
                      Colors.transparent,
                    ],
                    stops: const [0.12, 0.38, 0.72],
                  ),
                ),
              ),
            ),
          );
        }

        for (final hospital in _hospitals) {
          children.add(
            Positioned(
              left: constraints.maxWidth * hospital.x / 100 - 75,
              top: mapHeight * hospital.y / 100 - 24,
              child: _HospitalPin(hospital: hospital),
            ),
          );
        }

        return Stack(children: children);
      },
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8FBFF), AppColors.surfaceWarm, AppColors.surface],
        stops: [0, 0.62, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final grid = Paint()
      ..color = const Color(0x339BBCE2)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 46) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 46) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapLabel extends StatelessWidget {
  const _MapLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xAD00346F),
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _MapRoad extends StatelessWidget {
  const _MapRoad({
    required this.top,
    required this.left,
    required this.widthFactor,
    required this.angle,
    required this.label,
  });

  final double top;
  final double left;
  final double widthFactor;
  final double angle;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = MediaQuery.sizeOf(context).width;
          return Transform.rotate(
            angle: angle,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: math.min(620, math.max(280, width * widthFactor)),
              height: 24,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0x47004F9F), width: 3),
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xC700346F),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(color: Colors.white, offset: Offset(0, 1)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HospitalPin extends StatelessWidget {
  const _HospitalPin({required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xF0FFFFFF),
        border: Border.all(color: const Color(0x47004F9F)),
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x21061A3D),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x40D68A05), spreadRadius: 3),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              hospital.name,
              style: const TextStyle(
                color: AppColors.blueDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HospitalList extends StatelessWidget {
  const HospitalList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final hospital in _hospitals) ...[
          HospitalCard(hospital: hospital),
          if (hospital != _hospitals.last) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class HospitalCard extends StatelessWidget {
  const HospitalCard({required this.hospital, super.key});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEBFFFFFF),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        children: [
          const SymbolIcon(icon: Icons.local_hospital_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.name, style: AppText.sectionTitle(20)),
                const SizedBox(height: 4),
                Text(
                  '${hospital.district} - ${hospital.distance}',
                  style: AppText.paragraph,
                ),
                const SizedBox(height: 4),
                Text(
                  hospital.address,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            hospital.stock,
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ImpactPage extends StatelessWidget {
  const ImpactPage({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionGrid(
          left: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Impacto da doacao'),
              const SizedBox(height: 12),
              Text(
                'Sua doacao pode alimentar ate 3 bebes.',
                style: AppText.title(
                  MediaQuery.sizeOf(context).width <= 560 ? 34 : 60,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'O leite humano doado ajuda recem-nascidos internados, especialmente prematuros e bebes de baixo peso, a receberem nutricao segura em momentos criticos.',
                style: AppText.lead,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 13,
                runSpacing: 13,
                children: [
                  AppButton(
                    label: 'Quero doar leite',
                    onPressed: () => navigate('/doar'),
                  ),
                  AppButton(
                    label: 'Como funciona',
                    variant: ButtonVariant.ghost,
                    onPressed: () => navigate('/como-funciona'),
                  ),
                ],
              ),
            ],
          ),
          right: const ImpactPanel(),
        ),
        Section(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                eyebrow: 'Resultado esperado',
                title: 'O que muda quando a doacao entra na rede',
              ),
              const SizedBox(height: 22),
              ResponsiveGrid(
                minItemWidth: 240,
                gap: 16,
                children: [
                  for (final stat in _impactStats) ImpactCard(stat: stat),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ImpactPanel extends StatelessWidget {
  const ImpactPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 360),
      padding: const EdgeInsets.all(32),
      decoration: _panelDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceWarm],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '1 DOACAO',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text('3 bebes', style: AppText.title(76)),
          const SizedBox(height: 12),
          const Text(
            'Estimativa demonstrativa para o MVP, usada para mostrar ao doador o efeito direto da sua contribuicao.',
            style: AppText.paragraph,
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: _ImpactMeterBlock(color: AppColors.blueSoft)),
              SizedBox(width: 10),
              Expanded(child: _ImpactMeterBlock(color: AppColors.surfaceWarm)),
              SizedBox(width: 10),
              Expanded(child: _ImpactMeterBlock(color: AppColors.greenSoft)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactMeterBlock extends StatelessWidget {
  const _ImpactMeterBlock({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, AppColors.surface],
        ),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }
}

class ImpactCard extends StatelessWidget {
  const ImpactCard({required this.stat, super.key});

  final (String, String, String) stat;

  @override
  Widget build(BuildContext context) {
    final (value, label, text) = stat;

    return Container(
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 41,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.blueDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(text, style: AppText.paragraph),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    return SectionGrid(
      minHeight: math.max(0, MediaQuery.sizeOf(context).height - _headerHeight),
      left: const _LoginCopy(),
      right: LoginForm(navigate: navigate),
    );
  }
}

class _LoginCopy extends StatelessWidget {
  const _LoginCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Eyebrow('Entrada'),
        SizedBox(height: 12),
        Text(
          'Acesso ao painel gestor',
          style: TextStyle(
            color: AppColors.blueDark,
            fontFamily: 'Georgia',
            fontSize: 60,
            fontWeight: FontWeight.w700,
            height: 1.06,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'O painel e separado dos fluxos publicos. Profissionais de hospitais e bancos parceiros entram com seus dados antes de acessar indicadores e cadastros.',
          style: AppText.lead,
        ),
        SizedBox(height: 22),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            InfoChip('Acesso identificado'),
            InfoChip('Perfil institucional'),
            InfoChip('Painel operacional'),
          ],
        ),
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final TextEditingController _email;
  late final TextEditingController _senha;
  String _perfil = _defaultLogin['perfil']!;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: _defaultLogin['email']);
    _senha = TextEditingController(text: _defaultLogin['senha']);
  }

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: _panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FormTitle(
                icon: Icons.verified_user_outlined,
                eyebrow: 'Dados de acesso',
                title: 'Entrar no LatteConect',
              ),
              const SizedBox(height: 18),
              LabeledTextField(
                label: 'E-mail institucional *',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                required: true,
                placeholder: 'profissional@hospital.org',
              ),
              const SizedBox(height: 16),
              LabeledTextField(
                label: 'Senha *',
                controller: _senha,
                required: true,
                obscureText: true,
                placeholder: 'Digite sua senha',
              ),
              const SizedBox(height: 16),
              LabeledDropdown(
                label: 'Perfil de acesso',
                value: _perfil,
                items: const [
                  'Banco de leite',
                  'Hospital parceiro',
                  'Administrador',
                ],
                onChanged: (value) => setState(() {
                  _perfil = value;
                }),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Acessar painel ->',
                fullWidth: true,
                onPressed: () => widget.navigate('/painel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmationState extends StatelessWidget {
  const ConfirmationState({
    required this.navigate,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.details,
    required this.primaryAction,
    this.secondaryAction,
    this.icon = Icons.favorite_border,
    super.key,
  });

  final NavigateTo navigate;
  final String eyebrow;
  final String title;
  final String description;
  final List<(String, String)> details;
  final (String, String) primaryAction;
  final (String, String)? secondaryAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Section(
      top: 48,
      bottom: 48,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: math.max(
            0,
            MediaQuery.sizeOf(context).height - _headerHeight - 96,
          ),
        ),
        child: Center(
          child: Container(
            width: math.min(MediaQuery.sizeOf(context).width - 32, 760),
            padding: const EdgeInsets.all(32),
            decoration: _panelDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SymbolIcon(
                  icon: icon,
                  color: Colors.white,
                  background: AppColors.blue,
                  size: 72,
                ),
                const SizedBox(height: 16),
                Eyebrow(eyebrow),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppText.title(45),
                ),
                const SizedBox(height: 18),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppText.lead,
                ),
                const SizedBox(height: 22),
                SummaryList(items: details),
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: primaryAction.$2,
                      onPressed: () => navigate(primaryAction.$1),
                    ),
                    if (secondaryAction != null)
                      AppButton(
                        label: secondaryAction!.$2,
                        variant: ButtonVariant.ghost,
                        onPressed: () => navigate(secondaryAction!.$1),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageIntro(
          eyebrow: 'Painel gestor',
          title: 'Indicadores para decisao operacional',
          description:
              'O painel acompanha estoque, risco de queda nas doacoes e cadastros recentes para apoiar a equipe gestora.',
        ),
        DashboardPanel(navigate: navigate),
      ],
    );
  }
}

class DashboardPanel extends StatefulWidget {
  const DashboardPanel({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  State<DashboardPanel> createState() => _DashboardPanelState();
}

class _DashboardPanelState extends State<DashboardPanel> {
  late List<OperationalEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = getOperationalEvents();
  }

  void _refresh() {
    setState(() {
      _events = getOperationalEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final registeredDonors = _events
        .where((event) => event.kind == EventKind.cadastro)
        .length;
    final scheduledCollections = _events
        .where((event) => event.kind == EventKind.coleta)
        .length;
    final requests = _events
        .where((event) => event.kind == EventKind.pedido)
        .length;

    final metrics = [
      ('45 L', 'Estoque disponivel', 'blue'),
      ('${124 + registeredDonors}', 'Doadoras ativas', 'green'),
      ('$scheduledCollections', 'Coletas no painel', 'blue'),
      ('$requests', 'Pedidos recebidos', 'gold'),
    ];

    return Section(
      bottom: 64,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth <= 820;
              final heading = const SectionHeading(
                eyebrow: 'Gestao operacional',
                title: 'Painel do banco de leite',
              );
              final button = AppButton(
                label: 'Novo cadastro',
                variant: ButtonVariant.ghost,
                onPressed: () => widget.navigate('/doar'),
              );

              return stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [heading, const SizedBox(height: 16), button],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [heading, button],
                    );
            },
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth <= 1180;
              return narrow
                  ? ResponsiveGrid(
                      minItemWidth: 260,
                      gap: 16,
                      children: [
                        const StockCard(),
                        AlertCard(navigate: widget.navigate),
                        for (final metric in metrics)
                          MetricCard(metric: metric),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 260, child: StockCard()),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ResponsiveGrid(
                            minItemWidth: 170,
                            gap: 16,
                            fullWidthIndexes: const {0},
                            children: [
                              AlertCard(navigate: widget.navigate),
                              for (final metric in metrics)
                                MetricCard(metric: metric),
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 16),
          RecordsPanel(events: _events, onRefresh: _refresh),
        ],
      ),
    );
  }
}

class StockCard extends StatelessWidget {
  const StockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Estoque atual', style: AppText.paragraph),
          SizedBox(height: 8),
          Text(
            '45 L',
            style: TextStyle(
              color: AppColors.blue,
              fontSize: 45,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 20),
          Center(child: SizedBox(width: 190, height: 190, child: DonutChart())),
          SizedBox(height: 18),
          LegendItem(color: AppColors.blue, label: 'Disponivel'),
          SizedBox(height: 8),
          LegendItem(color: AppColors.sky, label: 'Reservado'),
          SizedBox(height: 8),
          LegendItem(color: Color(0xFFFFD18A), label: 'Meta'),
        ],
      ),
    );
  }
}

class DonutChart extends StatelessWidget {
  const DonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DonutPainter());
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.shortestSide * 0.18;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    const start = -math.pi / 2;
    final segments = [
      (AppColors.blue, 0.58),
      (AppColors.sky, 0.20),
      (const Color(0xFFFFD18A), 0.22),
    ];
    var cursor = start;
    for (final (color, value) in segments) {
      paint.color = color;
      final sweep = math.pi * 2 * value;
      canvas.drawArc(rect.deflate(stroke / 2), cursor, sweep, false, paint);
      cursor += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LegendItem extends StatelessWidget {
  const LegendItem({required this.color, required this.label, super.key});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(label, style: AppText.paragraph),
      ],
    );
  }
}

class AlertCard extends StatelessWidget {
  const AlertCard({required this.navigate, super.key});

  final NavigateTo navigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceSoft],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SymbolIcon(icon: Icons.notifications_none),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Alerta'),
                    const SizedBox(height: 6),
                    Text(
                      'Queda de doacoes prevista',
                      style: AppText.sectionTitle(29),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xE6FFFFFF),
              border: Border(left: BorderSide(color: AppColors.sky, width: 4)),
            ),
            child: const Text(
              'A analise das ultimas semanas indica reducao de 10% nas coletas previstas para a proxima semana.',
              style: AppText.paragraph,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => navigate('/hospitais'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.blue,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: const Text('Ver analise completa ->'),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({required this.metric, super.key});

  final (String, String, String) metric;

  @override
  Widget build(BuildContext context) {
    final (value, label, tone) = metric;
    final color = switch (tone) {
      'green' => AppColors.green,
      'gold' => AppColors.gold,
      _ => AppColors.blue,
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 35,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppText.paragraph),
        ],
      ),
    );
  }
}

class RecordsPanel extends StatelessWidget {
  const RecordsPanel({
    required this.events,
    required this.onRefresh,
    super.key,
  });

  final List<OperationalEvent> events;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _panelDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth <= 820;
              final title = Text(
                'Movimentacoes recentes',
                style: AppText.sectionTitle(26),
              );
              final button = AppButton(
                label: 'Atualizar',
                variant: ButtonVariant.ghost,
                onPressed: onRefresh,
              );

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.line)),
                ),
                child: mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [title, const SizedBox(height: 12), button],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [title, button],
                      ),
              );
            },
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FBFF)),
              columns: const [
                DataColumn(label: Text('Fluxo')),
                DataColumn(label: Text('Nome ou origem')),
                DataColumn(label: Text('Data e horario')),
                DataColumn(label: Text('Contato / local')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                for (final event in events)
                  DataRow(
                    cells: [
                      DataCell(
                        _TableStackedText(
                          primary: event.title,
                          secondary: event.kind.label,
                        ),
                      ),
                      DataCell(Text(event.subject)),
                      DataCell(
                        _TableStackedText(
                          primary: event.date,
                          secondary: event.time,
                          primaryBold: false,
                        ),
                      ),
                      DataCell(
                        _TableStackedText(
                          primary: event.contact,
                          secondary: event.location,
                          primaryBold: false,
                        ),
                      ),
                      DataCell(
                        StatusPill(label: event.status, tone: event.statusTone),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableStackedText extends StatelessWidget {
  const _TableStackedText({
    required this.primary,
    required this.secondary,
    this.primaryBold = true,
  });

  final String primary;
  final String secondary;
  final bool primaryBold;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          primary,
          style: TextStyle(
            color: AppColors.blueDark,
            fontWeight: primaryBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          secondary,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, required this.tone, super.key});

  final String label;
  final String tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      'green' => (const Color(0xFF1F7848), AppColors.greenSoft),
      'gold' => (const Color(0xFFA96000), AppColors.goldSoft),
      _ => (AppColors.blue, AppColors.blueSoft),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: colors.$1, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _param(LatteRoute route, String key, String fallback) {
  final value = route.query[key]?.trim();
  return value == null || value.isEmpty ? fallback : value;
}
