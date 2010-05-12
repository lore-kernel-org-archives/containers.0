From: Jean-Philippe Menil <jean-philippe.menil-zanJymNeSEOeCSforKHNpg@public.gmane.org>
Subject: Containerized syslog
Date: Wed, 12 May 2010 16:57:44 +0200
Message-ID: <4BEAC1E8.1070506__30999.314148403$1273676312$gmane$org@univ-nantes.fr>
Reply-To: jean-philippe.menil-zanJymNeSEOeCSforKHNpg@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070908040505020206000608"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------070908040505020206000608
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I'm playing with containers under debian (squeeze, 2.6.33.3) with the 
lxc tools.
I'm really happy about all the features (attach veth on bridge, filter 
with iptables inside the containers, etc ...), and i was thinking to 
replace some of our vservers (and maybe some of our kvm) with this solution.

But actually, i experiment a problem with the iptables logs:
i've iptables on the host to filter some container, basically a squid 
proxy. I've another container who act as router, and he has his own 
iptables inside.
All the log are deported to a dedicated syslog server.
It appear that, the iptables log of the host are also deported by the 
syslog container (proxy).

Some of our guest (container, vserver, etc ) are administer by other 
sys-admin, that should not have access to theses informations.

This point is blocking me today, before going into production with 
containers.

I've seen some patch made by Jean-Marc Pigeon about this problem,
but they have not been commited.

Is there any reason for that?
Can someone advice me to circumvent this problem?

Thanks a lot.

Regards.

--------------070908040505020206000608
Content-Type: text/x-vcard; charset=utf-8;
 name="jean-philippe_menil.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="jean-philippe_menil.vcf"

begin:vcard
fn:Jean-Philippe Menil
n:Menil;Jean-Philippe
org;quoted-printable:Universit=C3=A9 de Nantes;IRTS - DSI
adr;quoted-printable:;;2, rue de la Houssini=C3=A8re;Nantes;Loire-Atlantique;44332;France
email;internet:jean-philippe.menil-zanJymNeSEOeCSforKHNpg@public.gmane.org
title;quoted-printable:Administrateur R=C3=A9seau
tel;work:02.51.12.53.92
tel;fax:02.51.12.58.60
x-mozilla-html:FALSE
url:http://www.criun.univ-nantes.fr/
version:2.1
end:vcard


--------------070908040505020206000608
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------070908040505020206000608--
