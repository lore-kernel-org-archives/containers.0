From: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc : linux containers tool 0.6.0 release
Date: Mon, 23 Mar 2009 16:58:39 +0800
Message-ID: <d95d44a20903230158l42459b45x3cc5e0c05113bb04@mail.gmail.com>
References: <499EC673.8020808@fr.ibm.com>
	<d95d44a20903230048ke520376gd7701de00ff4e72d@mail.gmail.com>
	<20090323081810.GB2231@hack>
	<d95d44a20903230134j5d527b3cn3e7497069c128856@mail.gmail.com>
	<d95d44a20903230145m441abd8fga4bba277ba783e42@mail.gmail.com>
	<49C74DB3.50004@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C74DB3.50004-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

>
> What compilation error do you have ?
>

The compilation error is:

----------------------
...
In file included from start.c:55:
../../src/lxc/lxc.h:175: warning: type qualifiers ignored on function
return type
start.c: In function 'lxc_start':
start.c:339: error: 'PR_CAPBSET_DROP' undeclared (first use in this function)
start.c:339: error: (Each undeclared identifier is reported only once
start.c:339: error: for each function it appears in.)
...
---------------------

The libcap2 is installed manually by source codes
(from  http://ftp.kernel.org/pub/linux/libs/security/linux-privs/kernel-2.6/)
And then, I installed the libcap-devel-2.16
(from  ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/tiwai/openSUSE_10.3/i586/libcap-devel-2.16-2.1.i586.rpm)

In lxc-0.6.0 directory, "./configure" is ok, but "make" throw out the above
error message. It seems some predefination is lost.

Any help? maybe, something wrong in my installation.

Thanks,

anqin
