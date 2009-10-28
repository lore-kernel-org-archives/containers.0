From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] [RFC] Add file f_flags to cgroup write_string ops
Date: Wed, 28 Oct 2009 00:24:48 -0700
Message-ID: <20091028072448.GM31446@count0.beaverton.ibm.com>
References: <1256570129-13107-1-git-send-email-matthltc@us.ibm.com>
	<4AE7988A.6080601@cn.fujitsu.com>
	<6599ad830910272304j495c99a2t4265d501765937b5@mail.gmail.com>
	<6599ad830910272306t66994e12iec6d293f74fc4dc7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830910272306t66994e12iec6d293f74fc4dc7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 27, 2009 at 11:06:19PM -0700, Paul Menage wrote:
> On Tue, Oct 27, 2009 at 11:04 PM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > On Tue, Oct 27, 2009 at 6:04 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> >>
> >> I think maybe it's better to store struct file *file to struct cftype,
> >> so we don't need to change write_string(), write(), write_u64()
> >> and write_s64().
> >
> > We can't do that - multiple open files could be using the same cftype
> > at the same time. I'd be inclined if necessary to just pass the struct
> > file* in, rather than risk needing to change it to pass more
> > parameters later.
> 
> And I imagine that the number of handlers that actually make use of
> the cftype* is rather small. If we pass the file* to the handler
> instead of passing the cftype*, and provide an inline function to get
> from the file* to the cftype*, then we can avoid adding an extra
> parameter to the handlers.

OK, I've done this for write_string(). I named the inline function
cgroup_file_cftype(). It seems that, if we do this for one, then 
we should do it for all of the cgroup file io ops. Agreed?

Cheers,
	-Matt Helsley
