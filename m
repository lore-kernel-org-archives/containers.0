From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/4] Devices accessibility control group (v3, release
	candidate)
Date: Fri, 8 Feb 2008 10:12:17 -0600
Message-ID: <20080208161217.GA14201@sergelap.austin.ibm.com>
References: <47AAFFF2.9030804@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <47AAFFF2.9030804-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Pavel Emelyanov (xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> Changes from v2:
> * Fixed problems pointed out by Sukadev with permissions
>   revoke. Now we have to perform kobject re-lookup on
>   each char device open, just like for block ones, so I
>   think this is OK.
> 
> The /proc/devices tune is still in TODO list, as I have
> problems with getting majors _in_a_simple_manner_ from a 
> map, that contains a mix of major/minor pairs in 
> arbitrary order.

Thanks for posting, Pavel.  I'm sorry, I'm *trying* to review these, but
my eyes are glazing over.  (Not because of your patches I'll start by
just testing it a bit either this afternoon or monday.

thanks,
-serge

> The second version is here:
> http://openvz.org/pipermail/devel/2008-January/010160.html
> Changes from v1:
> 
> * Added the block devices support :) It turned out to
>   be a bit simpler than the char one (or I missed
>   something significant);
> * Now we can enable/disable not just individual devices,
>   but the whole major with all its minors (see the TODO
>   list beyond as well);
> * Added the ability to restrict the read/write permissions
>   to devices, not just visible/invisible state.
> 
> The first version was here:
> http://openvz.org/pipermail/devel/2007-September/007647.html
> 
> I still don't pay much attention to split this set well, so 
> this will most likely won't work with git-bisect, but I think 
> this is OK for now. I will sure split it better when I send 
> it to Andrew.
> 
> The set is prepared against the 2.6.24-rc8-mm1.
> 
> To play with it - run a standard procedure:
> 
>  # mount -t container none /cont/devs -o devices
>  # mkdir /cont/devs/0
>  # echo -n $$ > /cont/devs/0/tasks
> 
> and tune device permissions.
> 
> Thanks,
> Pavel
