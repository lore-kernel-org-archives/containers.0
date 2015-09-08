From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [RFC PATCH 0/2] Containerise nproc count
Date: Tue,  8 Sep 2015 11:11:11 +0300
Message-ID: <1441699873-26653-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>

Hello, 

This is an initial try to have nproc count apply per-userns, 
rather than per the global user struct. The implementation is 
really simple - a hashtable holding uid->nproc mapping for each
id inside the respective namespace. In its current form I have also
left the debugging code so that people who want to have a play with 
it can easily see what's happening. 

Now, this is only an RFC and I'd like to gather your thoughts about
the semantics. Currently as it stands I have tested the patchset by 
invoking multiple LXC containers, with identical uid mappings and 
users with the same uid inside the containers and it was working
correctly. 

There is an issue however, when using the unshare syscall and then doing
the mappings e.g. using "unshare -r" util from util-linux the initial process 
(the one which have done the unsharing) is accounted to the overflowuid but 
then again when exiting from the resulting shell the UID for user 0 is being 
freed which causes the BUG_ON in nsuser_nproc_dec to trigger. My initial idea 
for fixing this was to add code which upon writing to /proc/[pid]/uid_map  
would map all current processes from overflowuid to the 'ns->uid_map.extent[0].first'. 
This was working correctly but it was breaking the use case of lxc, since lxc is 
changing the uids after creating the uid_mapping (maybe this is a deficiency in the 
unshare util implementation?)

Another thing that needs improving is the locking occuring on the nsuser_nproc_hash, 
since in its current coarse-grained form it is serialisign process/thread creation on 
a per-usernamespace basis. 

I'm happy to discuss any concerns and improvements that people might have 
regarding this patchset. 


Nikolay Borisov (2):
  userns: Implement per-userns nproc infrastructure
  userns/nproc: Add hooks for userns nproc management

 include/linux/user_namespace.h |  15 +++++-
 kernel/cred.c                  |  36 +++++++++++++-
 kernel/exit.c                  |   9 ++++
 kernel/fork.c                  |  33 ++++++++++---
 kernel/user.c                  |   3 ++
 kernel/user_namespace.c        | 105 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 192 insertions(+), 9 deletions(-)

-- 
2.5.0
