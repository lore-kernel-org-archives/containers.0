From: MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
Subject: lxc performance?
Date: Wed, 06 Oct 2010 17:41:45 +0200
Message-ID: <4CAC98B9.4030903@univ-fcomte.fr>
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

  Hi all,
I subscribed in this list recently and i have some questions about lxc =

performance.
firstly, let me explain where i am using lxc:
i am using lxc with ns3 in order to simulate adhoc network where i will =

test my IDS(intrusion detection system for adhoc routing protocol).
i create until now only 10 containers with the same configuration (i =

based on the tutorial =

http://blog.bodhizazen.net/linux/lxc-configure-fedora-containers/)
my IDS is written in perl, using mysql dataBase and syslog service in =

order to collect, treating the logs of the simulation and apply the =

detection rules.
In order to have several types of devices(e.g., laptops, PDA and mobile =

telephone) in adhoc network, i need to create the lxc containers with =

different resources limits.
In other words, some of the containers must be powerful where others =

must be supplied with limited resources. Also, i have to test the =

effects of my IDS at the resources
(e.g, memory consumption)
Therefore, i used the next lxc-cgroup commands (recommended by Daniel =

lezcano):
lxc-cgroup -n dora1 memory.usage_in_bytes (to get the current used =

physical memory by the container dora1)
lxc-cgroup -n dora1 cpuacct.usage (to get the cpu sharing)
lxc-cgroup -n dora1 memory.limit_in_bytes 268435456 (to define the =

available memory for the container as 256MB)
Finally, my problem(after the long introduction :-) ):
the container dora1, where i launch an instance of my IDS, does not take =

more than 70 MB as memory even though the memory limit for it is much =

bigger than this value,
as a result the IDS works very slowly (the detection operation, which is =

composed of a simple perl script contacts with 3 tables in the DB, for 2 =

minutes of simulation takes more than 1 hour)

Someone has any idea how to give more resources for a container?
Creating several containers with different resources needs special =

configuration?


NB: lastly i tried to create only one container without connecting it =

with the ns3 simulation, but i still have the same problem.
i am using Ubuntu 10.04 lucid, the lxc system is fedora12

-- =

Mouhannad AlATTAR
Doctorant =E0 L=92UFR Sciences,Techniques et Gestion de l=92Industrie
P=F4le multimedia de Franche Comt=E9 - numerica
1, cours Leprince-Ringuet
25201 Montb=E9liard
Fixe bureau : 03 81 99 47 87
Portable : 06 16 71 05 10
