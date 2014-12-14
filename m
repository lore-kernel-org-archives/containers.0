From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [PATCH review 00/18] userns: review of bug fixes for 3.19-rcX
Date: Sun, 14 Dec 2014 20:41:11 +0100
Message-ID: <548DE7D7.3080607@nod.at>
References: <87k31wzehb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k31wzehb.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, kzak-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dottedmag-6nM9faFvqWvMFIMGWPqnnw@public.gmane.org
List-Id: containers.vger.kernel.org

Am 12.12.2014 um 23:32 schrieb Eric W. Biederman:
> 
> The entire tree for testing is available at:
> 	git.kernel.org:/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-testing
> 
> This is my queue of important bug fixes for user namespaces.  Most of
> these changes warrant being backported.  A few are bug fixes for cases
> where only root can trigger the issue so have not been marked for being
> back ported to stable.
> 
> A few of these patches have not been posted for review preivously, so I
> a giving the light of mailling list before I send them to Linus.  This
> patchset has seen some testing already. 
> 
> Since there are small deliberate breakage of userspace in here the more
> reviewers/testers the better.
> 
> Baring complictions I intend to ask Linus to pull this patchset sometime
> early next week.
> 
> So far nothing broke on my libvirt-lxc test bed. :-)
> Tested with openSUSE 13.2 and libvirt 1.2.9.
> Tested-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>

FYI, this change set breaks util-linux's unshare(1) tool
as an unprivileged is no longer allowed to write to /proc/self/gid_map.

Thanks,
//richard
