export async function api<T>(path: string, options?: RequestInit): Promise<T> {
  const csrfToken = sessionStorage.getItem("cms_csrf_token");
  const response = await fetch(path, {
    ...options,
    credentials: options?.credentials || "include",
    headers: {
      ...(options?.body instanceof FormData ? {} : { "Content-Type": "application/json" }),
      ...(csrfToken && ["POST", "PUT", "PATCH", "DELETE"].includes(options?.method || "GET")
        ? { "X-CSRF-Token": csrfToken }
        : {}),
      ...(options?.headers || {})
    }
  });
  if (!response.ok) {
    const body = await response.json().catch(() => ({ error: response.statusText }));
    throw new Error(body.error || "Request failed");
  }
  if (response.status === 204) return undefined as T;
  return response.json();
}
