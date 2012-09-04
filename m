From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Virtualizing /proc/sys/kernel/random/boot_id per container ?
Date: Tue, 4 Sep 2012 13:08:53 +0100
Message-ID: <20120904120853.GI7255@redhat.com>
References: <20120830211832.GA3297@redhat.com> <878vcwjabu.fsf@xmission.com>
	<20120830225002.GA9226@redhat.com> <87bohrhqai.fsf@xmission.com>
	<5044629C.3030909@parallels.com> <87r4qi6g6k.fsf@xmission.com>
	<5045BF05.9050707@parallels.com> <878vcq5ekx.fsf@xmission.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <878vcq5ekx.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Sep 04, 2012 at 02:20:46AM -0700, Eric W. Biederman wrote:
> Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:
> >> The twist of course is what does a boot mean.  If we are really after
> >> machine boots than the current behavior is correct.
> >> 
> >> Looking back in the archives the desired behavior appears to be a value
> >> that can be used to see if a pid value must be stale.
> >> 
> >> As a stale pid detector boot_id is pretty lousy.  Pids can still be
> >> reused.
> >> 
> >> Still a role as a stale pid detector makes it clear which namespace
> >> boot_id should be in and how we should treat boot_id upon migration.
> >> 
> >> You can only serve as a stale pid detector if you are in the pid
> >> namespace.
> >> 
> >> So at this point patches are welcome.  Hopefully with a summary
> >> of the discussion.
> >
> > Your discussion about boot_id being a limited solution is totally valid.
> > But it is orthogonal to the question of whether or not a container
> > should have it.
> 
> The important part is that boot_id as originally conceived is an
> identifier to be used in conjunction with pids.  Therefore boot_id is a
> proper pid_namespace component, and there are no semantic problems with
> putting it in the kernel.


> > boot_id as a pid namespace id is a very well defined concept.
> 
> Agreed.
> 
> A reference to the history and the definition needs to be in the patch
> description.

> > Then any tool could clone, mount proc, set this id, and continue
> > normally. Any objections ?
> 
> My biggest concern is that creating multiple pid namespaces might allow
> a way to drain the entropy pool in a way that we don't allow normal
> users.
> 
> This is important to look at as with a little luck we will have
> unprivileged creation of user namespaces and pid namespaces in the near
> future.

Unprivileged users can already ask the kernel to generate random UUIDs
on demand. eg

  $ sysctl kernel.random.uuid
  kernel.random.uuid = 76199778-8f6d-4fae-a45d-2c4cc0bca62a
  $ sysctl kernel.random.uuid
  kernel.random.uuid = 00c7d637-f94d-4df6-82c3-34ad97dd782e
  ...etc...

So allocating a new random UUID for boot_id each time a pid namespace
is created does not appear to make the situation worse wrt entropy
usage by unprivileged users.


Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
