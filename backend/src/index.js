const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config();

const swaggerUi = require('swagger-ui-express');
const specs = require('./config/swagger');
const workoutRoutes = require('./routes/workoutRoutes');
const routineRoutes = require('./routes/routineRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// API Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

// Routes
app.use('/api/workouts', workoutRoutes);
app.use('/api/routines', routineRoutes);

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date() });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on http://0.0.0.0:${PORT}`);
    console.log(`API Documentation at http://localhost:${PORT}/api-docs`);
});
