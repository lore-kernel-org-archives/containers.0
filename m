From: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v4] Introduce v3 namespaced file capabilities
Date: Tue, 13 Jun 2017 16:59:30 -0400
Message-ID: <1497387570.21594.427.camel__43687.2083032087$1497387592$gmane$org@linux.vnet.ibm.com>
References: <20170507092105.GA67584@inn.lkp.intel.com>
	<20170508044408.GA11400@mail.hallyn.com>
	<CACOXgS9a=avAWZEre1Q1CGjSHeq78Pkq1fYfwPjiyEX-u=B5wQ@mail.gmail.com>
	<20170508181156.GA23112@mail.hallyn.com>
	<9f80188c-df03-066a-5dac-785cc711d064@linux.vnet.ibm.com>
	<20170613171422.i5vsylhqqo736car@smitten>
	<1497375902.7379.25.camel@HansenPartnership.com>
	<20170613204612.uztqywc7topa6g2h@smitten>
	<8933bf11-7ca2-fa12-8d51-46d94d94a182@linux.vnet.ibm.com>
	<20170613205312.gre2s6a3zsrjnyos@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170613205312.gre2s6a3zsrjnyos@smitten>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tycho Andersen <tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>, Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2017-06-13 at 14:53 -0600, Tycho Andersen wrote:
> On Tue, Jun 13, 2017 at 04:49:03PM -0400, Stefan Berger wrote:
> > On 06/13/2017 04:46 PM, Tycho Andersen wrote:
> > > On Tue, Jun 13, 2017 at 10:45:02AM -0700, James Bottomley wrote:
> > > > On Tue, 2017-06-13 at 11:14 -0600, Tycho Andersen via Containers wrote:
> > > > > Hi Stefan,
> > > > > 
> > > > > On Tue, Jun 13, 2017 at 11:47:26AM -0400, Stefan Berger wrote:
> > > > > > On 05/08/2017 02:11 PM, Serge E. Hallyn wrote:
> > > > > > > Root in a non-initial user ns cannot be trusted to write a
> > > > > > > traditional security.capability xattr.  If it were allowed to do
> > > > > > > so, then any unprivileged user on the host could map his own uid
> > > > > > > to root in a private namespace, write the xattr, and execute the
> > > > > > > file with privilege on the host.
> > > > > > > 
> > > > > > > However supporting file capabilities in a user namespace is very
> > > > > > > desirable.  Not doing so means that any programs designed to run
> > > > > > > with limited privilege must continue to support other methods of
> > > > > > > gaining and dropping privilege.  For instance a program installer
> > > > > > > must detect whether file capabilities can be assigned, and assign
> > > > > > > them if so but set setuid-root otherwise.  The program in turn
> > > > > > > must know how to drop partial capabilities, and do so only if
> > > > > > > setuid-root.
> > > > > > Hi Serge,
> > > > > > 
> > > > > > 
> > > > > >    I have been looking at patch below primarily to learn how we
> > > > > > could apply a similar technique to security.ima and security.evm
> > > > > > for a namespaced IMA. From the paragraphs above I thought that you
> > > > > > solved the problem of a shared filesystem where one now can write
> > > > > > different security.capability xattrs by effectively supporting for
> > > > > > example security.capability[uid=1000] and
> > > > > > security.capability[uid=2000] written into the filesystem. Each
> > > > > > would then become visible as security.capability if the userns
> > > > > > mapping is set appropriately.
> > > > > One disadvantage of this approach is that whoever is setting up the
> > > > > container would need to go touch the security.ima attribute for each
> > > > > file in the contianer, which would slow down container creation time.
> > > > > For capabilities this makes sense, because you might want the file to
> > > > > have different capabilities in different namespaces, but for IMA,
> > > > > since the file hash will be the same in every namespace,
> > > > Actually, this isn't necessarily true: IMA may have the hash, you're
> > > > right, but I suspect in most container use cases it will have the
> > > > signature.  It's definitely a use case that the container will be using
> > > > a different keyring from the host, so different signatures are surely
> > > > possible for the same underlying image file.
> > > > 
> > > > One might imagine doing the above via overlays, because the new
> > > > signature should override the old.
> > > Yes, good point, thanks. Assuming the container and the host are using
> > > the same keyring, we could design it in such a way that the container
> > > engine doesn't need to touch every file on creation, which would be
> > > very nice.
> > 
> > I don't think this will be the general case. The host may be Ubuntu, the
> > guest could be Fedora and you'll have different keys. I don't think you
> > would want the container keys on the host keyring.
> 
> I guess it depends: if your entire infrastructure needs to be signed
> by your ops team, it would (presumably) all be the same ops key. If
> you're running off the shelf stuff from the distros or from a vendor,
> probably not, I agree.

Assuming you want to support container specific executables, you would
want them specifically signed by a key not on the system IMA keyring.

Mimi
