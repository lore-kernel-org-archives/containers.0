From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: how to do not allow to mount /cgroup inside container?
Date: Tue, 25 Aug 2009 14:17:39 +0200
Message-ID: <ac1c4bf20908250517j43d49f9fv1b5d6d5beae8aa@mail.gmail.com>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I was looking for possibility to secure lxc container to do not allow 'root
container user'  from changing limits from cgroup. Right now without STACK64
or SELinux he can do this easily.
I read the http://www.ibm.com/developerworks/linux/library/l-lxc-security/cookbook
and decided to use STACK64 kernel mechanism.
Well... mounting cgroup inside container fails (great!, i am looked for that
;)) but networking fails too (interface bring up, sshd bring up, connection
beetween host and container is, but 'mtr', 'ping' even 'apt-get update'
fails and I do not know why). I secure my container exactly like in the
cookbook.

Is there any other possilbility to have secure container without network
problems or any hint now to enable networking with stack64 enabled? If so,
maybe the l-lxc-security cookbook have to updated? Maybe another kernel
patch to do not allow container to mount cgroup when the mount call come
from container?

Any ideas?

-- 
Krzysztof Taraszka
