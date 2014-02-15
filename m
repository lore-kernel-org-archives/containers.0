From: Adam Richter <adam_richter2004-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: [Bisected] linux-audit in linux-3.14-rc1+ possibly breaking Linux
	Containers
Date: Fri, 14 Feb 2014 17:15:49 -0800 (PST)
Message-ID: <1392426949.59963.YahooMailNeo@web160601.mail.bf1.yahoo.com>
References: <1392418582.19695.YahooMailNeo@web160606.mail.bf1.yahoo.com>
Reply-To: Adam Richter <adam_richter2004-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1392418582.19695.YahooMailNeo-Y4cG9sIVSDivrfWm4H71L5EhsgyP+Z75VpNB7YpNyf8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi.

I just reported the following bug to linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org under a slightl=
y different subject line.=A0 I am forwarding it to containers-cunTk1MwBs9IKTv4iemRRA@public.gmane.org=
oundation.org so you can be aware the possible cause of this problem that a=
pparently effects Linux Containers.

Adam Richter

My bug report to linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org:
---------------------------------------------------------------------------=
--------------------------------


On Friday, February 14, 2014 2:56 PM, Adam Richter <adam_richter2004@yahoo.=
com> wrote:
 =

Hi.


If I take an Ubuntu 13.10-amd64 system and install an Ubuntu 13.04-i386 Lin=
ux Container, it works fine with kernel.org kernel releases through Linux-3=
.13, but, for Linux-13.14-rc1 and beyond, I cannot login with "lxc-console"=
.=A0 In that case, if I try to log in as "ubuntu" with the correct password=
, it quickly tell me the login was incorrect, and prompts me with a new "lo=
gin:" prompt, but without the delay that occurs if I type in the wrong pass=
word.=A0 I haven't bothered breaking into the "linux container", but, looki=
ng at its log files from the outside as it runs, I see some PAM errors abou=
t "operation not permitted."

I have reproduced this problem with the following container configurations,=
 all on an =

Ubuntu 13.10-amd64 hosts ("amd64" is Ubuntu's terminology, not my jibing In=
tel):

Ubuntu 13.04-i386
Ubuntu 13.10-i386
Ubuntu 13.10-amd64

I have also reproduced this with a kernel built from git://git.infradead.or=
g/users/eparis/audit.git yesterday (Ubuntu 13.10-amd64 hosting an Ubuntu
 13.04-i386 container).

I have also tried disabling CONFIG_AUDIT{SYSCALL,_WATCH,_TREE} and CONFIG_K=
VM_MMU_AUDIT from linux-3.14-rc2-x86_64 and still observed the same problem.

Doing a "git bisect" on Linus's public tree brought me to the following cha=
nge (Ubuntu 13.10-x86_64 hosting an Ubuntu 13.04-i386
 container):

33faba7fa7f2288d2f8aaea95958b2c97bf9ebfb is the first bad commit
commit 33faba7fa7f2288d2f8aaea95958b2c97bf9ebfb
Author: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date:=A0=A0 Tue Jul 16 13:18:45 2013 -0400

=A0=A0=A0 audit: listen in all network namespaces
=A0=A0=A0 =

=A0=A0=A0 Convert audit from only
 listening in init_net to use register_pernet_subsys()
=A0=A0=A0 to dynamically manage the netlink socket list.
=A0=A0=A0 =

=A0=A0=A0 Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
=A0=A0=A0 Signed-off-by: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

:040000 040000 3c5f63118d5fe9b5a4f0a6dd828249979a10ffa0 c8feaa4fd9bc260cde3=
bb703ff20ae6938fabe6a M=A0=A0=A0 kernel

For those of you who are not used to using Linux Containers, here are some =
commands that should reproduce the bug, although I am going from memory rat=
her than copying from my command history.

% sudo lxc-create -t ubuntu -n myubuntu13.04 -- --release raring --arch i386
# ^^ This takes a while.=A0 It installs a Linux distribution in a directory.

% sudo lxc-start -n myubuntu13.04 -d
% sudo lxc-console
 -n myubuntu13.04
...Try to log in as "ubuntu" with password "ubuntu".=A0 When you'd done, do=
 <ctrl-A>q to disconnect the session.
% sudo lxc-stop -n myubuntu13.04
# This next command basically does "rm -rf" on the container's directory tr=
ee.
% sudo lxc-destroy -n myubuntu13.04

In the above example, change "raring" to "saucy" if you want Ubuntu 13.10.=
=A0 You can change i386 to amd64 to try 64-bit.=A0 "myubuntu13.04" is just =
a name, which you can change to whatever you want.=A0 The Fedora container =
template shipped with Ubuntu 13.10 does not install for me, otherwise I wou=
ld have tested that too.

I am not yet sure if this is really a kernel bug or if this is a case of a =
valid change in Linux kernel behavior exposing a bug elsewhere (for example=
, Ubuntu's PAM configuration).=A0 I am not a Linux Audit developer.=A0 I am=
 hoping that, if this is a Linux Audit bug, you folks will be able to take =
it from here,
 but I'm happy to try to help as best I
 can.

Thanks in advance for any help with this.

Adam
