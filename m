From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/7] make CONFIG_CHECKPOINT
	dependonCONFIG_CHECKPOINT_SUPPORT
Date: Tue, 12 May 2009 09:29:12 -0500
Message-ID: <20090512142912.GA31449@us.ibm.com>
References: <1238022166-13422-1-git-send-email-ntl@pobox.com>
	<1238022166-13422-4-git-send-email-ntl@pobox.com>
	<FB599A4B-F618-4E6C-94D8-FC4EAE3D41D9@uni-duesseldorf.de>
	<20090512121001.GB28695@us.ibm.com>
	<3A15FE99-C94B-467B-B475-44BBED892C25@uni-duesseldorf.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3A15FE99-C94B-467B-B475-44BBED892C25-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ralph-Gordon Paul <Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Ralph-Gordon Paul (Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org):
> Ah okay sorry, i used this version: http://git.ncl.cs.columbia.edu/?p=linux-cr.git;a=shortlog;h=refs/heads/ckpt-v15
>
> Is this the official place to download the up to date version ?
>
> -Gordon

Hi Gordon,

yes, and you were right about needing compat vdso.  Sorry about the
inconvenience (since it was my patch).  I was just saying that since
Oren has added the underlying code for moving vdso around, there is no
reason why we shouldn't complete that support (with 1 line of code)
allowing us to remove the dependency on CONFIG_COMPAT_VDSO.

thanks,
-serge
