<?php
header('Content-Type: application/json');
header('X-Content-Type-Options: nosniff');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'message' => 'Method not allowed']);
    exit;
}

if (!empty($_POST['company'])) {
    http_response_code(200);
    echo json_encode(['ok' => true]);
    exit;
}

$recipient = 'info@adventuresafariafrica.com';
$sender = 'info@adventuresafariafrica.com';
$name = trim(preg_replace('/[\r\n]+/', ' ', strip_tags((string) ($_POST['name'] ?? ''))));
$email = trim((string) ($_POST['email'] ?? ''));

if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(422);
    echo json_encode(['ok' => false, 'message' => 'Please provide a valid name and email address.']);
    exit;
}

$allowedFields = [
    'language', 'contact', 'destination', 'countries', 'dates', 'flexible',
    'adults', 'children', 'days', 'style', 'occasion', 'flight_booked',
    'arrival_airport', 'arrival_date', 'departure_date', 'departure_airport',
    'safari_kind', 'interests', 'info', 'phone'
];

$bodyLines = [];
foreach ($allowedFields as $field) {
    if (!array_key_exists($field, $_POST)) {
        continue;
    }
    $value = $_POST[$field];
    if (is_array($value)) {
        $value = implode(', ', $value);
    }
    $value = trim(strip_tags((string) $value));
    if ($value !== '') {
        $bodyLines[] = ucfirst(str_replace('_', ' ', $field)) . ': ' . $value;
    }
}

$destination = trim(strip_tags((string) ($_POST['destination'] ?? 'Africa')));
$subject = 'Safari proposal request - ' . $destination;
$body = "New safari proposal request\n\n"
    . "Name: {$name}\n"
    . "Email: {$email}\n\n"
    . implode("\n", $bodyLines)
    . "\n\nSubmitted: " . gmdate('c') . "\n";

$headers = [
    'MIME-Version: 1.0',
    'Content-Type: text/plain; charset=UTF-8',
    'From: Adventure Safari Africa <' . $sender . '>',
    'Reply-To: ' . $name . ' <' . $email . '>'
];

if (!@mail($recipient, $subject, $body, implode("\r\n", $headers))) {
    http_response_code(502);
    echo json_encode(['ok' => false, 'message' => 'The mail server could not send this request.']);
    exit;
}

echo json_encode(['ok' => true]);
