From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 4/6] fs: Allow superblock owner to access
	do_remount_sb()
Date: Thu, 24 May 2018 11:45:06 -0500
Message-ID: <87603d3svh.fsf__45382.6481396847$1527180219$gmane$org@xmission.com>
References: <87o9h6554f.fsf@xmission.com>
	<20180523232538.4880-4-ebiederm@xmission.com>
	<20180524155803.GB19932@mailbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180524155803.GB19932-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org> (Christian Brauner's message
	of "Thu, 24 May 2018 17:58:03 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org> writes:

> On Wed, May 23, 2018 at 06:25:36PM -0500, Eric W. Biederman wrote:
>> Superblock level remounts are currently restricted to global
>> CAP_SYS_ADMIN, as is the path for changing the root mount to
>> read only on umount. Loosen both of these permission checks to
>> also allow CAP_SYS_ADMIN in any namespace which is privileged
>> towards the userns which originally mounted the filesystem.
>
> Acked-by: Christian Brauner <christian-STijNZzMWpgWenYVfaLwtA@public.gmane.org>
>
>> 
>> Signed-off-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>
> Note, I just talked to Serge. This should be Acked-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

Now you know how long these patches have been sitting waiting to get
merged.

Eric
