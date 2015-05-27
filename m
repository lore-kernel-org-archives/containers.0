From: Josh Boyer <jwboyer-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
Subject: Re: Kernel panic with user namespaces
Date: Wed, 27 May 2015 10:06:53 -0400
Message-ID: <CA+5PVA7wpFwMSHkAQoVzthYSrxJXfpZo5vLGKYAHggN+ujJyow__45493.3277368129$1432735632$gmane$org@mail.gmail.com>
References: <1431959951.5030.2.camel@redhat.com>
	<1432642765.19400.2.camel@redhat.com>
	<87vbff1es3.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87vbff1es3.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Linux-Kernel@Vger. Kernel. Org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, May 26, 2015 at 12:31 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Alexander Larsson <alexl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>
>> On m=E5n, 2015-05-18 at 16:39 +0200, Alexander Larsson wrote:
>>
>> Didn't get any replies to the below kernel panic (testcase attached),
>> which seems rather important to fix. Reposting to a wider audience.
>
> Buggered backport greg already has the fix somewhere in his queue.

Is it fs_pin-allow-for-the-possibility-that-m_list-or-s_list-go-unused.patch
or mnt-fail-collect_mounts-when-applied-to-unmounted-mounts.patch ?
(Or both I guess.)  Those are the only 2 patches queued for 4.0 stable
right now.

josh
