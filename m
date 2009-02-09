From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: bootstrap problem
Date: Mon, 09 Feb 2009 18:12:25 +0100
Message-ID: <499063F9.301@free.fr>
References: <7B7881568CF40E4388B615CD06F87B98098977@clara.maurer-it.com>
	<49806250.2000503@free.fr>
	<7B7881568CF40E4388B615CD06F87B98098979@clara.maurer-it.com>
	<498077E5.4000403@free.fr>
	<7B7881568CF40E4388B615CD06F87B98098980@clara.maurer-it.com>
	<4980B9A0.7060507@free.fr>
	<7B7881568CF40E4388B615CD06F87B980989DA@clara.maurer-it.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <7B7881568CF40E4388B615CD06F87B980989DA-cHQ43lMKbBKenyD9vqZGNUEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Dietmar Maurer wrote:
>> cvs -d:pserver:anonymous-HKWriCeapa2nJ6BriqaqdGjI4wXNbHj0@public.gmane.org:/cvsroot/lxc login
>> cvs -z3 -d:pserver:anonymous-HKWriCeapa2nJ6BriqaqdGjI4wXNbHj0@public.gmane.org:/cvsroot/lxc co
>>     
> -P
>   
>> /lxc/
>>     
>
> lxc# ./bootstrap
> + test -d autom4te.cache
> + ACLOCAL_AMFLAGS='-I m4 -I config '
> + libtoolize --force
> You should add the contents of `/usr/share/aclocal/libtool.m4' to
> `aclocal.m4'.
> Putting files in AC_CONFIG_AUX_DIR, `config'.
> + aclocal -I m4 -I config
> aclocal: couldn't open directory `m4': No such file or directory
> + exit 1
>
> I manually create the dir:
>
> # mkdir m4
>
> the bootstrap works
>
> - Dietmar
>   
Fixed.
Thanks Dietmar.
