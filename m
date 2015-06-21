From: Mail Delivery Subsystem <MAILER-DAEMON-mO9HgdVS6DSHv8ceEPPTOipxlwaOVQ5f@public.gmane.org>
Subject: Returned mail: see transcript for details
Date: Sun, 21 Jun 2015 06:52:59 +0200
Message-ID: <201506210452.t5L4qxjA011482@smtp31.msg.oleane.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0470379896455117888=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-encapsulated message

--===============0470379896455117888==
Content-Type: multipart/report; report-type=delivery-status;
	boundary="t5L4qxjA011482.1434862379/smtp31.msg.oleane.net"

This is a MIME-encapsulated message

--t5L4qxjA011482.1434862379/smtp31.msg.oleane.net

The original message was received at Sun, 21 Jun 2015 06:52:57 +0200
from localhost.localdomain [127.0.0.1]

   ----- The following addresses had permanent fatal errors -----
<pierrepbahette-FvCWP+l5LIY@public.gmane.org>
    (reason: 550 5.1.1 <pierrepbahette-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table)
<philippepbonnet-FvCWP+l5LIY@public.gmane.org>
    (reason: 550 5.1.1 <philippepbonnet-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table)
<phanesmallet-FvCWP+l5LIY@public.gmane.org>
    (reason: 550 5.1.1 <phanesmallet-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table)

   ----- Transcript of session follows -----
... while talking to [217.109.114.182]:
>>> DATA
<<< 550 5.1.1 <phanesmallet-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table
550 5.1.1 <phanesmallet-FvCWP+l5LIY@public.gmane.org>... User unknown
<<< 550 5.1.1 <philippepbonnet-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table
550 5.1.1 <philippepbonnet-FvCWP+l5LIY@public.gmane.org>... User unknown
<<< 550 5.1.1 <pierrepbahette-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table
550 5.1.1 <pierrepbahette-FvCWP+l5LIY@public.gmane.org>... User unknown

--t5L4qxjA011482.1434862379/smtp31.msg.oleane.net
Content-Type: message/delivery-status

Reporting-MTA: dns; smtp31.msg.oleane.net
Received-From-MTA: DNS; localhost.localdomain
Arrival-Date: Sun, 21 Jun 2015 06:52:57 +0200

Final-Recipient: RFC822; pierrepbahette-FvCWP+l5LIY@public.gmane.org
Action: failed
Status: 5.1.1
Remote-MTA: DNS; [217.109.114.182]
Diagnostic-Code: SMTP; 550 5.1.1 <pierrepbahette-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table
Last-Attempt-Date: Sun, 21 Jun 2015 06:52:58 +0200

Final-Recipient: RFC822; philippepbonnet-FvCWP+l5LIY@public.gmane.org
Action: failed
Status: 5.1.1
Remote-MTA: DNS; [217.109.114.182]
Diagnostic-Code: SMTP; 550 5.1.1 <philippepbonnet-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table
Last-Attempt-Date: Sun, 21 Jun 2015 06:52:58 +0200

Final-Recipient: RFC822; phanesmallet-FvCWP+l5LIY@public.gmane.org
Action: failed
Status: 5.1.1
Remote-MTA: DNS; [217.109.114.182]
Diagnostic-Code: SMTP; 550 5.1.1 <phanesmallet-FvCWP+l5LIY@public.gmane.org>: Recipient address rejected: User unknown in relay recipient table
Last-Attempt-Date: Sun, 21 Jun 2015 06:52:58 +0200

--t5L4qxjA011482.1434862379/smtp31.msg.oleane.net
Content-Type: text/rfc822-headers

Return-Path: <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Received: from smtp31.msg.oleane.net (localhost.localdomain [127.0.0.1]) 
	by smtp31.msg.oleane.net (MX-AV) with ESMTP id t5L4qvjA011457;
	Sun, 21 Jun 2015 06:52:57 +0200
Received: from bodymen.arvixecloud.com (bodymen.arvixecloud.com [192.169.60.151]) 
	by smtp31.msg.oleane.net (MX) with ESMTP id t5L4quUS011436;
	Sun, 21 Jun 2015 06:52:56 +0200
Received: from [192.169.60.151] by bodymen.arvixecloud.com id alVscmmhbFJ4 with SMTP; Sat, 20 Jun 2015 21:52:58 -0700
Date: Sat, 20 Jun 2015 21:52:58 -0700
From: <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
X-Mailer: The Bat! (v3.5.87.5) Educational
X-Priority: 3 (Normal)
Message-ID: <170178610.92159646423046-OVU3vqUZ1pyg1FoiY4FZ46QeRxPp7hef@public.gmane.org>
To: <phanesmallet-FvCWP+l5LIY@public.gmane.org>
Subject: Facture commerciale 6651079096.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Backend: vm-mx-sophos29v4
X-PFSI-Info: PMX 6.0.0.2142326, Antispam-Engine: 2.7.2.2107409, Antispam-Data: 2015.6.21.43316 (no virus found)

--t5L4qxjA011482.1434862379/smtp31.msg.oleane.net--


--===============0470379896455117888==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============0470379896455117888==--
