From: joeyli <jlee-IBi9RG/b67k@public.gmane.org>
Subject: Re: [CFT][PATCH] mnt: Implicitly add MNT_NODEV on remount when it
	was implicitly added by mount
Date: Tue, 2 Dec 2014 21:12:22 +0800
Message-ID: <20141202131222.GC29118@linux-rxt1.site>
References: <547B309E.9020706@nod.at>
	<CALCETrUZRi=Y=CDTpq5oO-tPOvMsZ+osKiydkCk-P0dn4DKJkA@mail.gmail.com>
	<547B34C6.6030709@nod.at>
	<CALCETrW6QRRB_DfHwYv+UVJ_8yF+8Db+UP+ezd4jG599b4dSiA@mail.gmail.com>
	<547B5066.4020509@nod.at> <871tokleo7.fsf@x220.int.ebiederm.org>
	<547B6531.40504@nod.at> <87k32ci2dx.fsf@x220.int.ebiederm.org>
	<547D77C8.7050100@nod.at> <87ppc22x9d.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ppc22x9d.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Jim Fehlig <jfehlig-IBi9RG/b67k@public.gmane.org>, Cedric Bosdonnat <cbosdonnat-IBi9RG/b67k@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Eric, 

On Tue, Dec 02, 2014 at 03:53:34AM -0600, Eric W. Biederman wrote:
> Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> writes:
> 
> > Am 01.12.2014 um 02:29 schrieb Eric W. Biederman:
> >>>>>> Any chance you can test that with Eric's patch or mine [1] applied?
> >>>>>> If that doesn't work, can you try to catch the failure with strace?
> >>>>>
> >>>>> With your patch applied on top of Linus's tree as of today libvirt-lxc works fine again. :)
> >>>>
> >>>> *Scratches head*
> >>>>
> >>>> Did you really have my latest patch applied?
> >>>>
> >>>> Andy's patch implies a change of policy that I really don't want to
> >>>> deploy as a bug fix.
> >>>
> >>> Hmm, let me double check this tomorrow with a fresh brain.
> >>> Maybe I got hit by another issue while testing your patch.
> >>> Currently I'm fighting against three libvirt-lxc issues in parallel. :-\
> >> 
> >> Please do.  I just reran through my regression tests that explore this
> >> issue rather throughly and all of my remount test cases are passing.  So
> >> if things are truly failing I want to understand what is going on, and
> >> add to my regression tests.
> >> 
> >> I should have done that sooner of course but I am still paging back in
> >> after being distracted with the other things in life.
> >
> > I can confirm that your patch "mnt: Implicitly add MNT_NODEV on remount as we do on mount"
> > unbreaks libvirt-lxc too. :-)
> > Sorry for the false negative.
> 
> Thanks I will add your Tested-by.
> 
> Eric

Cedric help to test my kernel that included your patch. Please feel free to
add:

Tested-by: Cedric Bosdonnat <cbosdonnat-IBi9RG/b67k@public.gmane.org>


Regards
Joey Lee
