#ifndef included_IBBeamForceSpec
#define included_IBBeamForceSpec

// Filename: IBBeamForceSpec.h
// Last modified: <28.Mar.2007 20:39:40 griffith@box221.cims.nyu.edu>
// Created on 22 Mar 2007 by Boyce Griffith (griffith@box221.cims.nyu.edu)

/////////////////////////////// INCLUDES /////////////////////////////////////

// IBAMR INCLUDES
#include <ibamr/Stashable.h>

// SAMRAI INCLUDES
#include <tbox/AbstractStream.h>

// C++ STDLIB INCLUDES
#include <utility>
#include <vector>

/////////////////////////////// CLASS DEFINITION /////////////////////////////

namespace IBAMR
{
/*!
 * \brief Class IBBeamForceSpec provies a mechanism for specifying the
 * data necessary to compute the forces generated by a network of
 * linear beams.  By beam, here we mean a structure that resists
 * bending.
 *
 * Beams are connections between three particular nodes of the
 * Lagrangian mesh.  IBBeamForceSpec objects are stored as Stashable
 * data associated with only the master beam nodes in the mesh.
 */
class IBBeamForceSpec
    : public Stashable
{
public:
    /*!
     * \note Use of the following typedef is needed in order to get
     * g++ to compiler to parse the default parameters in the class
     * constructor.
     */
    typedef std::pair<int,int> pair_int_int;

    /*!
     * \brief Register this class and its factory class with the
     * singleton StashableManager object.  This method must be called
     * before any IBBeamForceSpec objects are created.
     *
     * \note This method is collective on all MPI processes.  This is
     * done to ensure that all processes employ the same stashable ID
     * for the IBBeamForceSpec class.
     */
    static void registerWithStashableManager();

    /*!
     * \brief Returns a boolean indicating whether the class has been
     * registered with the singleton StashableManager object.
     */
    static bool getIsRegisteredWithStashableManager();

    /*!
     * \brief Default constructor.
     */
    IBBeamForceSpec(
        const int master_idx=-1,
        const std::vector<pair_int_int>& neighbor_idxs=std::vector<pair_int_int>(),
        const std::vector<double>& bend_rigidities=std::vector<double>());

    /*!
     * \brief Virtual destructor.
     */
    virtual ~IBBeamForceSpec();

    /*!
     * \return The number of beams attatched to the master node.
     */
    unsigned getNumberOfBeams() const;

    /*!
     * \return A const refernce to the master node index.
     */
    const int& getMasterNodeIndex() const;

    /*!
     * \return A non-const reference to the master node index.
     */
    int& getMasterNodeIndex();

    /*!
     * \return A const refrence to the neighbor node indices for the
     * beams attached to the master node.
     */
    const std::vector<pair_int_int>& getNeighborNodeIndices() const;

    /*!
     * \return A non-const refrence to the neighbor node indices for
     * the beams attached to the master node.
     */
    std::vector<pair_int_int>& getNeighborNodeIndices();

    /*!
     * \return A const reference to the bending rigidities of the
     * beams attached to the master node.
     */
    const std::vector<double>& getBendingRigidities() const;

    /*!
     * \return A non-const reference to the bending rigidities of the
     * beams attached to the master node.
     */
    std::vector<double>& getBendingRigidities();

    /*!
     * \brief Return the unique identifier used to specify the
     * StashableFactory object used by the StashableManager to extract
     * Stashable objects from data streams.
     */
    virtual int getStashableID() const;

    /*!
     * \brief Return an upper bound on the amount of space required to
     * pack the object to a buffer.
     */
    virtual size_t getDataStreamSize() const;

    /*!
     * \brief Pack data into the output stream.
     */
    virtual void packStream(
        SAMRAI::tbox::AbstractStream& stream);

private:
    /*!
     * \brief Default constructor.
     *
     * \note This constructor is not implemented and should not be
     * used.
     */
    IBBeamForceSpec();

    /*!
     * \brief Copy constructor.
     *
     * \note This constructor is not implemented and should not be
     * used.
     *
     * \param from The value to copy to this object.
     */
    IBBeamForceSpec(
        const IBBeamForceSpec& from);

    /*!
     * \brief Assignment operator.
     *
     * \note This operator is not implemented and should not be used.
     *
     * \param that The value to assign to this object.
     *
     * \return A reference to this object.
     */
    IBBeamForceSpec& operator=(
        const IBBeamForceSpec& that);

    /*!
     * Indicates whether the factory has been registered with the
     * StashableManager.
     */
    static bool s_registered_factory;

    /*!
     * The stashable ID for this object type.
     */
    static int s_stashable_id;

    /*!
     * Data required to define the beam forces.
     */
    int d_num_beams, d_master_idx;
    std::vector<pair_int_int> d_neighbor_idxs;
    std::vector<double> d_bend_rigidities;
};
}// namespace IBAMR

/////////////////////////////// INLINE ///////////////////////////////////////

//#include <ibamr/IBBeamForceSpec.I>

//////////////////////////////////////////////////////////////////////////////

#endif //#ifndef included_IBBeamForceSpec
