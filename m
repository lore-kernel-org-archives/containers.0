From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: sysctl variables are not available to newly created namespace
Date: Thu, 28 Jul 2016 10:51:10 -0500
Message-ID: <87y44liwwh.fsf@x220.int.ebiederm.org>
References: <8FAD92B89CFCF442A932848BE6809DD30A1277@G4W3221.americas.hpqcorp.net>
	<877fc5kidj.fsf@x220.int.ebiederm.org>
	<43CB8A4DE9C2424AA6598497DD8046CB4686C94D@SRVBAN19MBXPH02.corp.mphasis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <43CB8A4DE9C2424AA6598497DD8046CB4686C94D-KkfHdg/VLJFHExuseMmLQexR1G140wlwz0iUvNCykH4@public.gmane.org>
	(Madhukrishna G.'s message of "Thu, 28 Jul 2016 13:57:56 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Madhukrishna G <Madhukrishna.G-068NM081eCxBDgjK7y7TUQ@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Madhukrishna G <Madhukrishna.G-068NM081eCxBDgjK7y7TUQ@public.gmane.org> writes:

> Hi Eric,
>
> Thanks for your reply.
>
> Can you please let me know the patch for this fix or kernel version
> where the fix was integrated.

To be clear the behavior (not all sysctls being visible) is the fix.
The old behavior was buggy.

As for what/when/where I don't recall the details clearly.  That change
happened years ago.  If you want to figure it out you can look at
net/net_sysctl.c:register_net_sysctl() and look into it's history in
git.

Eric
