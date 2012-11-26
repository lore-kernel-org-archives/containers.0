From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Mon, 26 Nov 2012 09:16:06 -0600
Message-ID: <87sj7wwg21.fsf__38091.5202237249$1353943029$gmane$org@xmission.com>
References: <50A9EAD8.9090501@gmail.com>
	<20121119143702.GB4620@mail.hallyn.com> <50ACA05F.7080005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50ACA05F.7080005-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Rui Xiang's message of "Wed, 21 Nov
	2012 17:35:27 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 2012-11-19 22:37, Serge E. Hallyn wrote:

>> I understand that user namespaces aren't 100% usable yet, but looking
>> long term, is there a reason to have the syslog namespace separate
>> from user namespace?
>
> Actually we don't have strong preference. We'll think more about it. Hope we can make
> consensus with Eric.

I hope I am not hard to work with.  My primary concern is reasonable
looking code and good long term maintainable semantics.

I really don't care in which namespace where we file the kernel log
statements.

I care much more about which kernel log print statements we want filed
differently.

Eric
