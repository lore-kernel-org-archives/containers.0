From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: Re: [stable] Locked mount and loopback mount fixes
Date: Sun, 10 May 2015 21:23:01 -0500
Message-ID: <AD3FF3AE-4EC2-4239-97C6-96A1818E8856__30798.3954590329$1431311016$gmane$org@xmission.com>
References: <1431280791.2233.50.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1431280791.2233.50.camel-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org



On May 10, 2015 12:59:51 PM CDT, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org> wrote:
>Why were these not cc'd to stable?  Was this an oversight, or are they
>simply not needed for fixing any known bugs?

An oversight.

On their own they don't matter but other patches cc'd to stable do depend on them for correct operation.

The fact most of these changes depends on fs_pin likely limits how far they may be bsckported.

>commit cd4a40174b71acd021877341684d8bb1dc8ea4ae
>Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>Date:   Wed Jan 7 14:28:26 2015 -0600
>
>    mnt: Fail collect_mounts when applied to unmounted mounts
>
>commit 820f9f147dcce2602eefd9b575bbbd9ea14f0953
>Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>Date:   Thu Apr 2 16:35:48 2015 -0500
>
>    fs_pin: Allow for the possibility that m_list or s_list go unused.

Eric
