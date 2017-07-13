From: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Thu, 13 Jul 2017 15:14:29 -0400
Message-ID: <20170713191429.vfaetqscxd7hniwq@thunk.org>
References: <1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87mv89iy7q.fsf@xmission.com>
	<20170712170346.GA17974@mail.hallyn.com>
	<877ezdgsey.fsf@xmission.com>
	<74664cc8-bc3e-75d6-5892-f8934404349f@linux.vnet.ibm.com>
	<20170713011554.xwmrgkzfwnibvgcu@thunk.org>
	<87y3rscz9j.fsf@xmission.com>
	<20170713164012.brj2flnkaaks2oci@thunk.org>
	<29fdda5e-ed4a-bcda-e3cc-c06ab87973ce@linux.vnet.ibm.com>
	<8760ew9qyp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8760ew9qyp.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 13, 2017 at 12:39:10PM -0500, Eric W. Biederman wrote:
> > Can you define what 'scalable' means for you in this context?
> > From what I can see sharing a filesystem between multiple containers
> > doesn't 'scale well' for virtualizing the xattrs primarily because of
> > size limitations of xattrs per file.
> 
> Worse than that I believe you will find that filesystems are built on
> the assumption that there will be a small number of xattrs per file.
> So even if the vfs limitations were lifted the filesystem performance
> would suffer.

That's why I've been pushing here.  If people try to do

   security.capable@uid=1000
   security.capable@uid=2000
   security.capable@uid=3000
   security.capable@uid=4000
   security.capable@uid=5000
   security.capable@uid=6000
   security.capable@uid=7000
   security.capable@uid=8000
   security.capable@uid=9000
         .
	 .
	 .

... where the values of all of these will be the same, this is going
to be *awful* even if the file system can support it.

So maybe we are better off if we define an xattr

   security.capable@guest-container

... so the property is that it is ignored by the host ("real")
container, and in all of the subcontainers, it will be used if the
local container root is trying to execute the file.

Now, this doesn't support the solution of the "turtles all the way
down" insane containers configuraiton.

E.g., where in one container we boot a RHEL distro, which then
launches another container running another RHEL distro, and repeat
this 1000 times, for a very deeply nested subsubsubsubsub...container.

I think this is insane and we shouldn't support this, but I know there
are people who think this is a perfectly sane thing to do.


The other thing this doesn't support is someone who wants to use IMA,
and where the every single IMA is using a different signed HMAC:

   security.ima@uid=1000
   security.ima@uid=2000
   security.ima@uid=3000
   security.ima@uid=4000
   security.ima@uid=5000
   security.ima@uid=6000
   security.ima@uid=7000
   security.ima@uid=8000
   security.ima@uid=9000
	.
	.
	.

Where each security IMA could either be a 32 byte HMAC, or worse, a
256 byte RSA signed signature.  Now let's assume there are 10,000
containers, each of which needs a separate RSA signature.  This sounds
insane.... but I've seen things that I've thought were more insane
coming out of containerland, so it would be nice if we can get
something signed in blood promisng that no, we would *never* do
something that insane, or better yet, make it impossible to do from an
architectural standpoint.

					- Ted
