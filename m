From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v2] locks: Filter /proc/locks output on proc pid ns
Date: Wed, 3 Aug 2016 11:06:31 -0400
Message-ID: <20160803150631.GA3789@fieldses.org>
References: <1470148943-21835-1-git-send-email-kernel@kyup.com>
	<1470209710-30022-1-git-send-email-kernel@kyup.com>
	<1470232012.18285.4.camel@poochiereds.net>
	<57A1FCE5.3040206@kyup.com> <57A205BE.3070202@virtuozzo.com>
	<57A20702.3040805@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57A20702.3040805-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>, Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 03, 2016 at 06:00:18PM +0300, Nikolay Borisov wrote:
> 
> 
> On 08/03/2016 05:54 PM, Pavel Emelyanov wrote:
> > On 08/03/2016 05:17 PM, Nikolay Borisov wrote:
> >>
> >>
> [SNIP]
> >>
> >> [CCing some people from openvz/CRIU]
> > 
> > Thanks :)
> > 
> >> My train of thought was "we should have means which would be the one
> >> universal truth about everything and this would be a process in the
> >> init_pid_ns". I don't have strong preference as long as I'm not breaking
> >> userspace. As I said before - I think the CRIU guys might be using that
> >> interface.
> > 
> > This particular change won't break us mostly because we've switched to
> > reading the /proc/pid/fdinfo/n files for locks.
> 
> [thinking out loud here]
> 
> I've never actually looked into those files but now that I have it seems
> to make sense to also switch 'lsof' to actually reading the locks from
> the available pids directories rather than relying on the global
> /proc/locks interface. Oh well :)

Digging around...  Oh, I see, there's an optional 'lock:..' line in
/proc/[pid]/fdinfo/[pid] file, is that what you're looking at?  I'd
forgotten.  Yeah, maybe that would make more sense long term.

--b.

> 
> [/thinking out loud here]
> 
> > 
> > -- Pavel
> > 
> >>>
> >>>>>> +	    && (proc_pidns != ns_of_pid(fl->fl_nspid)))
> >>>>> +		return 0;
> >>>> +
> >>>>>  	lock_get_status(f, fl, iter->li_pos, "");
> >>>>  
> >>>>>  	list_for_each_entry(bfl, &fl->fl_block, fl_block)
> >>>
> >> .
> >>
> > 
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linuxfoundation.org/mailman/listinfo/containers
> > 
