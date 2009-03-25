From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH] Add powerpc signalfd syscall numbers
Date: Wed, 25 Mar 2009 14:00:09 +0100
Message-ID: <49CA2AD9.7030908@free.fr>
References: <20090320054420.GB26719@us.ibm.com>	<20090320060903.GA4360@us.ibm.com>
	<49C39BA9.5090404@free.fr>	<m1iqlxx11n.fsf@fess.ebiederm.org>
	<49CA214B.1090301@free.fr> <m1tz5hvkxo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1tz5hvkxo.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, LXC Development <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> writes:
>
>   
>> I resurrected it for lxc userspace tool.
>>     
>
> Makes sense.  I had not seen that before.
>
> On that note I need to expect I need to sync up on user space tools
> so that we can have one default tool that works for everyone.
>   
Yes, that makes sense.
At present there are several people using it and proposing improvements 
or fixes on this mailing list.
The lxc tools will be in the opensuse 11.2 distro and is in the debian 
wishlist.

The main goal of the tool is to have a suiss army knif, most of the 
options are configurable.
The tools allow to do a simple unshare as well as booting a debian minimal.

The philosophy is to have something tunable acting at a low level and 
let the user to script the configuration of the container.

An overview:
http://lxc.sourceforge.net/lxc.html

The code is browsable here:
http://lxc.git.sourceforge.net/

The git is accessible here:
|git-clone git://lxc.git.sourceforge.net/gitroot/lxc|

Regards.
  -- Daniel
