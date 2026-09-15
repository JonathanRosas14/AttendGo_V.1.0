export interface PasswordV0{
    value: string;
}

export function validatePasswordStrength(password: string): { valid: boolean; errors: string[]
}{
    const errors: string[] = [];

    if (password.length < 8) errors.push('Minimo 8 caracteres');
    if (!/[A-Z]/.test(password)) errors.push('Al menos 1 mayuscula');
    if (!/[0-9]/.test(password)) errors.push('Al menos 1 numeros');
    if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) errors.push('Al menos 1 simbolo');

    return {valid:errors.length ===0, errors}
}

export function validateEmail(email: string): boolean{
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
