From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4] Introduce v3 namespaced file capabilities
Date: Tue, 13 Jun 2017 18:50:25 -0500
Message-ID: <20170613235025.GB15685@mail.hallyn.com>
References: <20170507092105.GA67584@inn.lkp.intel.com>
	<20170508044408.GA11400@mail.hallyn.com>
	<CACOXgS9a=avAWZEre1Q1CGjSHeq78Pkq1fYfwPjiyEX-u=B5wQ@mail.gmail.com>
	<20170508181156.GA23112@mail.hallyn.com>
	<9f80188c-df03-066a-5dac-785cc711d064@linux.vnet.ibm.com>
	<20170613234214.GA15685@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170613234214.GA15685-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > On 05/08/2017 02:11 PM, Serge E. Hallyn wrote:
> > >Root in a non-initial user ns cannot be trusted to write a traditional
> > >security.capability xattr.  If it were allowed to do so, then any
> > >unprivileged user on the host could map his own uid to root in a private
> > >namespace, write the xattr, and execute the file with privilege on the
> > >host.
> > >
> > >However supporting file capabilities in a user namespace is very
> > >desirable.  Not doing so means that any programs designed to run with
> > >limited privilege must continue to support other methods of gaining and
> > >dropping privilege.  For instance a program installer must detect
> > >whether file capabilities can be assigned, and assign them if so but set
> > >setuid-root otherwise.  The program in turn must know how to drop
> > >partial capabilities, and do so only if setuid-root.
> > 
> > Hi Serge,
> > 
> > 
> >   I have been looking at patch below primarily to learn how we could
> > apply a similar technique to security.ima and security.evm for a
> > namespaced IMA. From the paragraphs above I thought that you solved
> > the problem of a shared filesystem where one now can write different
> > security.capability xattrs by effectively supporting for example
> > security.capability[uid=1000] and security.capability[uid=2000]
> 
> Interesting idea.  Worth considering.
> 
> > written into the filesystem. Each would then become visible as
> > security.capability if the userns mapping is set appropriately.
> > However, this doesn't seem to be how it is implemented. There seems
> 
> Indeed, when I was considering supporting multiple simulatenous
> xattrs, I did it as something like:
> 
> struct vfs_ns_cap_data {
> 	struct {
> 		__le32 permitted;
> 		__le32 inheritable;
> 	} data[VFS_CAP_U32];
> 	__le32 rootid;
> };
> 
> struct vfs_ns_cap {
> 	__le32 magic_etc;
> 	__le32 n_entries;
> 	struct ns_cap_data data[0];
> }; // followed by n_entries of struct ns_cap_data
> 
> You're instead suggesting encoding the rootuid in the name,
> which is interesting.
> 
> > to be only a single such entry with uid appended to it and, if it
> > was a shared filesystem, the first one to set this attribute blocks
> > everyone else from writing the xattr. Is that how it works? Would
> 
> Approximately - indeed there is only a single xattr.  But it can be
> overwritten, so long as the writer has CAP_SETFCAP over the user_ns
> which mounted the filesystem.

Hang on.  I've mis-spoken.  That's the requirement for writing a
v2 xattr.  To write a v3 xattr you only need to be privileged
(with CAP_SETFCAP) against the inode.
