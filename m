From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Tue, 28 Oct 2008 14:00:52 -0700
Message-ID: <1225227652.12673.190.camel@nimitz>
References: <1225219047.12673.182.camel@nimitz>
	<20081028205654.GA17487@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081028205654.GA17487-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2008-10-28 at 15:56 -0500, Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > I hate the syscall.  It's a very un-Linux-y way of doing things.  There,
> 
> Not really the syscall, but the writing to the file from the kernel.
> Any time I see set_fs(KERNEL_DS) i get flashbacks to getting yelled at
> in the 90s :)

Heh.  You security whackos are always getting yelled at for _something_
anyway.

> > I said it.  Here's an alternative.  It still uses the syscall to
> > initiate things, but it uses debugfs to transport the data instead.
> > This is just a concept demonstration.  It doesn't actually work, and I
> > wouldn't be using debugfs in practice.
> 
> It's neat how few lines this took, but I would prefer using a tiny
> custom fs rather than use debugfs for dump and configfs for restore.

Yeah, doing a new FS would certainly be a ton more code.  But, I think
the most important part ends up being how complicated it ends up being
in practice.

It may turn out that refactoring some existing debug/configfs code might
be enough to get us there without too much new code *just* for us.

> If you like I can take a shot at whipping up the new mini-fs, though
> I think you're having fun :)

I need to look into what configfs can give me, next.  I'll keep
playing. :)

I really just wanted to know what Oren and Andrey thought.

-- Dave
