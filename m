From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: After lxc-execute command terminal hangs
Date: Wed, 24 Aug 2011 10:00:25 +0200
Message-ID: <4E54AF99.9080506@free.fr>
References: <CAHnfO6wpNqO=PuiSJTu=9B3p1XQdgs_SV=0owK0yxxSYk__VVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHnfO6wpNqO=PuiSJTu=9B3p1XQdgs_SV=0owK0yxxSYk__VVw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/24/2011 09:08 AM, nishant mungse wrote:
> Hii all
>
> I am using lxc for creating containers.
>
>  But when i create lxc container using "lxc-create -n abc" it creates a abc
> container and when i do lxc-info -n abc its show "abc is stopped" and when i
> perform "lxc-start -n abc [-f conf file ]" the terminal hangs and if do
> "lxc-execute -n abc [-f conf file ] \bin\bash" terminal hangs.
>
> It is not even working for  "/usr/bin/lxc-execute -n foo -f
> /usr/share/doc/lxc/examples/lxc-macvlan.conf /bin/bash".
>
> I am using UBUNTU 10.10.
>
> Plz help me ASAP.

Wrong mailing list. Please use lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

Thanks
  -- Daniel
