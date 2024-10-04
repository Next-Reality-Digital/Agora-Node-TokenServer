# Stage 1: Install dependencies and build the application
FROM node:16 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) to leverage Docker layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application source code
COPY . .

# (Optional) Build the application
# If your Express app uses a build step (e.g., TypeScript compilation), uncomment the following line
# RUN npm run build

# Stage 2: Create the production image
FROM node:16-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) from the builder stage
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy the application source code from the builder stage
COPY --from=builder /app ./

# (Optional) If you have a build step, copy the built files
# If you used a build step in Stage 1, ensure the build artifacts are copied over
# COPY --from=builder /app/dist ./dist

# Expose the port the app runs on (ensure this matches your Express app's port)
EXPOSE 3000

# Define environment variables with default values (can be overridden at runtime)
ENV PORT=3000

# Define the command to run the application
CMD ["node", "index.js"]
