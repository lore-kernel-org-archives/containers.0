From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v10][PATCH 09/13] Restore open file descriprtors
Date: Mon, 01 Dec 2008 11:22:04 -0800
Message-ID: <1228159324.2971.74.camel__30427.5004230023$1228159571$gmane$org@nimitz>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	<1227747884-14150-10-git-send-email-orenl@cs.columbia.edu>
	<20081128112745.GR28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081128112745.GR28946-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-11-28 at 11:27 +0000, Al Viro wrote:
> On Wed, Nov 26, 2008 at 08:04:40PM -0500, Oren Laadan wrote:
> > +/**
> > + * cr_attach_get_file - attach (and get) lonely file ptr to a file descriptor
> > + * @file: lonely file pointer
> > + */
> > +static int cr_attach_get_file(struct file *file)
> > +{
> > +	int fd = get_unused_fd_flags(0);
> > +
> > +	if (fd >= 0) {
> > +		fsnotify_open(file->f_path.dentry);
> > +		fd_install(fd, file);
> > +		get_file(file);
> > +	}
> > +	return fd;
> > +}
> 
> What happens if another thread closes the descriptor in question between
> fd_install() and get_file()?

You're just saying to flip the get_file() and fd_install()?

> > +	fd = cr_attach_file(file);	/* no need to cleanup 'file' below */
> > +	if (fd < 0) {
> > +		filp_close(file, NULL);
> > +		ret = fd;
> > +		goto out;
> > +	}
> > +
> > +	/* register new <objref, file> tuple in hash table */
> > +	ret = cr_obj_add_ref(ctx, file, parent, CR_OBJ_FILE, 0);
> > +	if (ret < 0)
> > +		goto out;
> 
> Who said that file still exists at that point?

Ahhh.  We're depending on the 'struct file' reference that comes from
the fd table.  That's why there is supposedly "no need to cleanup 'file'
below".  But, some other thread can come along and close() the fd, which
will __fput() our poor 'struct file' and will make it go away.  Next
time we go and pull it out of the hash table, we go boom.

As a quick fix, I think we can just take another get_file() here.  But,
as Al notes, there are some much larger issues that we face with the
fd_table and multi-thread access.  They haven't "mattered" to us so far
because we assume everything is either single-threaded or frozen.
Sounds like Al isn't comfortable with this being integrated until a much
more detailed look has been taken.

> BTW, there are shitloads of races here - references to fd and struct file *
> are mixed in a way that breaks *badly* if descriptor table is played with
> by another thread.

One of the things about this that bothers me is that it shares too
little with existing VFS code.  It calls into a ton of existing stuff
but doesn't refactor anything that is currently there.  Surely there are
some common bits somewhere in the VFS that could be consolidated here.  

-- Dave
