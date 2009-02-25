From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] keys: make procfiles per-user-namespace
Date: Wed, 25 Feb 2009 15:03:36 -0600
Message-ID: <20090225210336.GA20086@us.ibm.com>
References: <20090223204041.GA31626@us.ibm.com>
	<20090109225313.GB15599@us.ibm.com>
	<20090109225208.GA15252@us.ibm.com>
	<5296.1234522990@redhat.com> <16728.1235565664@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <16728.1235565664-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > > Hmmm...  I wonder if we can do better by making the file position indicate
> > > the key ID rather than being a count of the number of keys read.  It might
> > > make this cleaner.
> > 
> > file position?  as in the result of lseek(fd, 0, SEEK_CUR)?
> > 
> > I don't understand what you're suggesting.
> 
> Currently the file position on /proc/keys indicates the number of keys that
> have been read.  It is incremented by 1 for each key read, irrespective of the
> length of the line that was read for that key.
> 
> We could, instead, map file positions to key IDs, and skip any file positions
> that don't actually map to an extant key.

So you want users to be able to mmap the file and lseek to a particular
spot?  Is that bc you have users with so many keys that
	grep keyid /proc/keys
becomes slow?

Or am I still misunderstanding?

Meanwhile, do you have any objections to these 4 patches?  :)

thanks,
-serge
