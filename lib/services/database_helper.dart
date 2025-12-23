import 'package:money_move/models/deuda.dart';
import 'package:sqflite/sqflite.dart'
    hide Transaction; // El motor de base de datos
import 'package:path/path.dart'; // Para encontrar la ruta en el celular
import '../models/transaction.dart'; // Tu modelo de datos

class DatabaseHelper {
  // 1. EL SINGLETON (Patrón de diseño)
  // Esto asegura que solo exista UNA instancia del mayordomo en toda la app.
  // Si abrieras dos conexiones al mismo tiempo, podrías corromper el archivo.
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init(); // Constructor privado

  // 2. OBTENER LA BASE DE DATOS
  // Si ya existe, la devuelve. Si no, la inicializa (abre el archivo).
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('money_move.db'); // Nombre del archivo
    return _database!;
  }

  // 3. ABRIR CONEXIÓN
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Abre la base de datos. Si no existe, ejecuta _createDB
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // 4. CREAR LA TABLA (SQL)
  // Esto se ejecuta solo la primera vez que se instala la app.
  Future _createDB(Database db, int version) async {
    // Definimos los tipos de datos de SQL
    const idType = 'TEXT PRIMARY KEY'; // UUID es texto
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL'; // REAL es decimal
    const intType = 'INTEGER NOT NULL'; // SQLite usa 1 y 0 para booleanos

    await db.execute('''
      CREATE TABLE transactions ( 
        id $idType, 
        title $textType,
        description $textType,
        monto $doubleType,
        fecha $textType,
        categoria $textType,
        isExpense $intType
      )
    ''');

    // --- TABLA 2: DEUDAS
    await db.execute('''
      CREATE TABLE deudas ( 
        id $idType, 
        title $textType,
        description $textType,
        monto $doubleType,   
        involucrado $textType,  
        abono $doubleType,       
        fechaInicio $textType,  
        fechaLimite $textType,   
        categoria $textType,   
        debo $intType,    
        pagada $intType     
      )
    ''');
  }

  // --- MÉTODOS CRUD (Create, Read, Update, Delete) ---

  // A. INSERTAR
  Future<void> insertTransaction(Transaction t) async {
    final db = await instance.database;
    // Usamos el toMap() que creaste en el paso anterior
    // conflictAlgorithm: si ya existe el ID, lo reemplaza
    await db.insert(
      'transactions',
      t.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // B. LEER TODAS
  Future<List<Transaction>> getAllTransactions() async {
    final db = await instance.database;

    // Pedimos ordenar por fecha (más reciente primero)
    final result = await db.query('transactions', orderBy: 'fecha DESC');

    // Convertimos la lista de Mapas a lista de Objetos Transaction
    return result.map((json) => Transaction.fromMap(json)).toList();
  }

  // C. BORRAR
  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;

    return await db.delete(
      'transactions',
      where: 'id = ?', // ? es un placeholder de seguridad
      whereArgs: [id], // Aquí va el valor real
    );
  }

  Future<int> updateTransaction(Transaction t) async {
    final db = await instance.database;

    return await db.update(
      'transactions',
      t.toMap(),
      where: 'id = ?', // Buscamos por ID
      whereArgs: [t.id], // Pasamos el ID de la transacción a actualizar
    );
  }

  // ----------- CRUD DE DEUDAS ------------

  // A. INSERTAR DEUDA
  Future<void> insertDeuda(Deuda d) async {
    final db = await instance.database;
    await db.insert(
      'deudas', // <--- Nombre de la nueva tabla
      d.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // B. LEER TODAS LAS DEUDAS
  Future<List<Deuda>> getAllDeudas() async {
    final db = await instance.database;
    final result = await db.query(
      'deudas',
      orderBy: 'fechaLimite ASC',
    ); // Ordenar por urgencia
    return result.map((json) => Deuda.fromMap(json)).toList();
  }

  // C. ACTUALIZAR DEUDA (Ej: Marcar como pagada)
  Future<int> updateDeuda(Deuda d) async {
    final db = await instance.database;
    return await db.update(
      'deudas',
      d.toMap(),
      where: 'id = ?',
      whereArgs: [d.id],
    );
  }

  // D. BORRAR DEUDA
  Future<int> deleteDeuda(String id) async {
    final db = await instance.database;
    return await db.delete('deudas', where: 'id = ?', whereArgs: [id]);
  }
}
