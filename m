From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 16/29] A new file type (CR_FD_OBJREF) for
	a file descriptor already setup
Date: Wed, 1 Apr 2009 13:36:09 -0500
Message-ID: <20090401183609.GB16973@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-17-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-17-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> While file pointers are shared objects, they may share an underlying
> object themselves. For instance, file pointers of both ends of a pipe
> that share the same pipe inode. In this case, the shared entity to
> handle is the inode that is shared among two file pointers (e.g read-
> and write- ends). In this sort of "nested sharing" we need only save
> the underlying object once (upon first encounter) on checkpoint, and
> restore it only once during restart.
> 
> To checkpoint a file descriptor of this sort, we first lookup the
> inode in the hash table:
> 
> If not found, it is the first encounter of this inode. Here, Besides
> the file descriptor data, we also (a) register the inode in the hash
> and save the corresponding 'objref' of this inode in '->fd_objref' of
> the file descriptor. We then also (b) save the inode data, as per the
> inode type (this is not implemented in this patch, as it depends on
> the object). The file descriptor type will indicate the type of that
> object (e.g. for a pipe, when supported, CR_FD_PIPE).
> 
> If found, it is the second encounter of this inode, e.g. in the case
> of a pipe, as we hit the other end of the same pipe. At this point we
> need only record the reference ('objref') to the inode that we had
> saved before, and the file descriptor type is changed to CR_FD_OBJREF.
> 
> The logic during restart is similar: the '->fd_objref' is looked up in
> the hash table. Unlike checkpoint, during restart the object that is
> placed (and sought) in the hash table is the _file_ pointer, rather
> than the _inode_.
> 
> If not found, it is the first encounter of this inode. Therefore we
> (a) restore the inode data. Specifically, we construct a matching
> object and end up with multiple file pointers (e.g. if the object is a
> pipe, we will have both read- and write- ends). One of those is used
> for the file descriptor in question; the other(s) will be deposited in
> the hash table, to be retrieved and used later on. We also (b) register
> the newly created inode in the hash table using the given 'objref'.
> 
> If found, then we can skip the setup of the underlying object that
> is represented by the inode.
> 
> The type CR_FD_OBJREF indicates, on restart, that the corresponding
> file descriptor is already setup and registered in the hash under the
> '->fd_objref' that it had been assigned.
> 
> The next two patches use CR_FD_OBJREF to implement support for pipes.
> 
> Changelog[v14]:
>   - Introduce patch
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

-serge
