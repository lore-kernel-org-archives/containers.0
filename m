From: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: After lxc-execute command terminal hangs
Date: Wed, 24 Aug 2011 12:38:47 +0530
Message-ID: <CAHnfO6wpNqO=PuiSJTu=9B3p1XQdgs_SV=0owK0yxxSYk__VVw@mail.gmail.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hii all

I am using lxc for creating containers.

 But when i create lxc container using "lxc-create -n abc" it creates a abc
container and when i do lxc-info -n abc its show "abc is stopped" and when i
perform "lxc-start -n abc [-f conf file ]" the terminal hangs and if do
"lxc-execute -n abc [-f conf file ] \bin\bash" terminal hangs.

It is not even working for  "/usr/bin/lxc-execute -n foo -f
/usr/share/doc/lxc/examples/lxc-macvlan.conf /bin/bash".

I am using UBUNTU 10.10.

Plz help me ASAP.

Regards,
Nishant.
