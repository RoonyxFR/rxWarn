CREATE TABLE `warns` (
  `id` int(11) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `raison` varchar(255) NOT NULL,
  `date` varchar(50) NOT NULL,
  `warn_by` varchar(255) NOT NULL,
  `identifier_warn_by` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `warns`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `warns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
COMMIT;
