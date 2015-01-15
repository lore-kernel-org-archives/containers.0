From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Detecting the use of a mount in another namespace
Date: Thu, 15 Jan 2015 10:34:17 +0000
Message-ID: <20150115103417.GC8057@redhat.com>
References: <1421312165.8788.7.camel@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1421312165.8788.7.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jan 15, 2015 at 09:56:05AM +0100, Alexander Larsson wrote:
> This is a bit of a weird request, but I'm working on an app sandboxing
> system where each container gets /usr read-only bind mounted from a
> hardlinked tree. When i update the /usr tree I write the new tree to a
> different directory, which avoids affecting any currently running apps
> against the old one.
> 
> However, after updating I'd like to clean out the old version if it is
> not in use. I had a plan for this:
> 1) Move the old usr to a "has been deleted" location
> 2) Try to remove a file inside the user (say ".ref") which the app when
> running has bind-mounted somewhere
> 3) if the remove returned EBUSY, then the usr is in use.
> 
> However, with the recent changes to the semantics in this area this
> doesn't work. The remove always succeeds even if the file is mounted in
> some other namespace.
> 
> I realize that this is better semantics in general, but that was a quite
> useful hack. Is there any other similar way i can detect that something
> is in use in "any other namespace".

Presumably you want something more efficient than scaning /proc/$PID in
the host OS ? eg you read /proc/$PID/mounts for each process, then iterate
stating /proc/$PID/root/<mount> to lookup the st_dev+st_inode of the mount
location to see if the one you care about still exists in any process ?
Not really going to scale nicely with large numbers of $PIDs, so perhaps
you could short circuit by keeping track of your container pid leaders ?

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
