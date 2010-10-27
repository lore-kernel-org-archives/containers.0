From: MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
Subject: several mysql-connections problem
Date: Wed, 27 Oct 2010 17:57:35 +0200
Message-ID: <4CC84BEF.1070807@univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
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
List-Id: containers.vger.kernel.org

Hi,
I have several lxc (fedora12) working under Ubuntu 10.10 host.
With one container i can connect to mysql database without any problem.
When i launched simultaneously several containers and tried to connect =

to mysql database from each one of them, mysql service starts is ok
but connecting to the database will not be possible only from one =

container. Trying to connect to mysql from another container will figure =

out the next error:
"Can't connect to local MySQL server through socket =

'/var/lib/mysql/mysql.sock'"
I think this error happens because the container, which connects to =

mysql, reserves the mysql.sock or other mysql configuration files and =

prevents other nodes to use them!!!!
N.B: the last container starting mysql service is the one that is able =

to connecting to the database

any suggestion to resolve this problem?
a+

-- =

Mouhannad AlATTAR
Doctorant =E0 L=92UFR Sciences,Techniques et Gestion de l=92Industrie
P=F4le multimedia de Franche Comt=E9 - numerica
